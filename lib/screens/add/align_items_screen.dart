import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'save_item_screen.dart';

/// ระยะขอบระหว่างกรอบเส้นประกับรูป asset (พิกเซลบนจอ)
const double _kGuidePad = 10;

// ============================================================
// Guide type
// ============================================================

/// ชนิดของ guide ที่เลือกได้จากเมนู Elements
///
/// asset ต้องเป็น PNG พื้นโปร่งใส อยู่ที่
/// assets/templates/<id>/<id>_overlay.png
enum GuideType {
  shirt('Shirt', 'shirt', 0.95, 1.05, Icons.checkroom_outlined),
  tshirt('T-Shirt', 'tshirt', 0.95, 1.00, Icons.checkroom_outlined),
  pants('Pants', 'pants', 0.7, 1.60, Icons.straighten_outlined),
  short('Shorts', 'shorts', 0.95, 0.90, Icons.crop_portrait_outlined);

  const GuideType(
    this.label,
    this.id,
    this.widthFactor,
    this.fallbackAspect,
    this.icon,
  );

  final String label;
  final String id;

  /// ความกว้างของรูป asset เทียบกับความกว้างพื้นที่กล้อง (0-1)
  /// เพิ่มค่านี้ถ้าอยากให้ asset ใหญ่ขึ้นอีก
  final double widthFactor;

  /// สัดส่วน สูง/กว้าง ที่ใช้เมื่อโหลด asset ไม่ได้
  final double fallbackAspect;
  final IconData icon;

  String get assetPath => 'assets/templates/$id/${id}_overlay.png';
}

// ============================================================
// Screen
// ============================================================

class AlignItemsScreen extends StatefulWidget {
  const AlignItemsScreen({super.key, this.imagePath});

  /// ถ้ามีค่า = โหมดรูปจาก gallery (ข้ามกล้อง ใช้รูปนี้แทน)
  /// ถ้าเป็น null = โหมดกล้อง (พฤติกรรมเดิม)
  final String? imagePath;

  /// true เมื่อมาจาก gallery (ไม่ต้องเปิดกล้อง)
  bool get isGalleryMode => imagePath != null;

  @override
  State<AlignItemsScreen> createState() => _AlignItemsScreenState();
}

class _AlignItemsScreenState extends State<AlignItemsScreen> {
  CameraController? _controller;

  GuideType _guide = GuideType.tshirt;
  bool _menuOpen = false;
  bool _busy = false;

  /// ไบต์ของ overlay ที่เลือกอยู่ (ใช้ทำ mask) และสัดส่วนจริงของรูป
  Uint8List? _overlayBytes;
  double? _overlayAspect;

  /// ขนาดพื้นที่ preview ล่าสุด (อัปเดตใน LayoutBuilder) ใช้ตอน crop
  Size _previewBox = Size.zero;

  // ---------- gallery pan/zoom (เฉพาะโหมด gallery) ----------

  /// ขนาดจริง (พิกเซล) ของรูปที่เลือกจาก gallery
  Size? _galleryImageSize;

  /// scale ที่ใช้ตอนวางรูปให้ cover พื้นที่ preview ครั้งแรก (ก่อนผู้ใช้ซูม/ลาก)
  double? _coverScale;

  /// true เมื่อคำนวณตำแหน่งเริ่มต้นของรูป (จัดกึ่งกลางแบบ cover) เสร็จแล้ว
  bool _transformReady = false;

  final TransformationController _transformController =
      TransformationController();

  double get _aspect => _overlayAspect ?? _guide.fallbackAspect;

  @override
  void initState() {
    super.initState();
    if (widget.isGalleryMode) {
      // โหมด gallery ไม่ต้องเปิดกล้อง แต่ต้องรู้ขนาดจริงของรูปก่อน
      // เพื่อคำนวณตำแหน่งเริ่มต้น (cover) ให้ InteractiveViewer
      _loadGalleryImageSize();
    } else {
      _initCamera();
    }
    _loadGuide(_guide);
  }

  Future<void> _loadGalleryImageSize() async {
    try {
      final bytes = await File(widget.imagePath!).readAsBytes();
      final image = await decodeImageFromList(bytes);
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();

      if (!mounted) return;
      setState(() => _galleryImageSize = size);
    } catch (e) {
      debugPrint('Load gallery image size failed: $e');
    }
  }

  /// จัดรูปให้ cover พื้นที่ preview พอดีตอนเปิดหน้าครั้งแรก (เหมือนโหมดกล้อง)
  /// เรียกครั้งเดียวหลังจากรู้ทั้งขนาดรูปและขนาดพื้นที่ preview แล้ว
  void _initGalleryTransform() {
    if (_transformReady) return;
    final size = _galleryImageSize;
    if (size == null || _previewBox.isEmpty) return;

    final coverScale = _max(
      _previewBox.width / size.width,
      _previewBox.height / size.height,
    );
    final dx = (_previewBox.width - size.width * coverScale) / 2;
    final dy = (_previewBox.height - size.height * coverScale) / 2;

    _coverScale = coverScale;
    _transformController.value = Matrix4.identity()..translate(dx, dy);

    setState(() => _transformReady = true);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  /// โหลด asset ของ guide เพื่อรู้สัดส่วนจริง และเก็บไบต์ไว้ทำ mask ตอนถ่าย
  Future<void> _loadGuide(GuideType type) async {
    Uint8List? bytes;
    double? aspect;
    try {
      final data = await rootBundle.load(type.assetPath);
      bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final image = await decodeImageFromList(bytes);
      aspect = image.height / image.width;
      image.dispose();
    } catch (e) {
      debugPrint('Load guide asset failed (${type.assetPath}): $e');
      bytes = null;
      aspect = null;
    }

    // ถ้าระหว่างโหลดผู้ใช้เปลี่ยนชนิดไปแล้ว ให้ทิ้งผลนี้
    if (!mounted || _guide != type) return;
    setState(() {
      _overlayBytes = bytes;
      _overlayAspect = aspect;
    });
  }

  void _selectGuide(GuideType type) {
    setState(() {
      _guide = type;
      _overlayBytes = null;
      _overlayAspect = null;
      _menuOpen = false;
    });
    _loadGuide(type);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  // ---------- guide geometry ----------

  /// ขนาด "กรอบเส้นประ" (รวม padding) ภายในพื้นที่ [box]
  /// ใช้ฟังก์ชันเดียวกันทั้งตอนวาดและตอน crop เพื่อให้ตรงกันเสมอ
  Size _guideSizeFor(Size box, GuideType type, double aspect) {
    var innerW = box.width * type.widthFactor;
    var innerH = innerW * aspect;

    final maxInnerH = box.height * 0.92 - _kGuidePad * 2;
    if (innerH > maxInnerH) {
      innerH = maxInnerH;
      innerW = innerH / aspect;
    }
    return Size(innerW + _kGuidePad * 2, innerH + _kGuidePad * 2);
  }

  // ---------- capture ----------

  /// จุดเริ่มของทั้งสองโหมด: กล้อง -> ถ่ายรูปก่อนแล้ว crop, gallery -> crop
  /// จากรูปที่เลือกไว้เลย ทั้งคู่ใช้สูตร crop/mask ชุดเดียวกัน (BoxFit.cover)
  Future<void> _takePhoto() async {
    if (_busy || _previewBox.isEmpty) return;

    if (widget.isGalleryMode) {
      setState(() {
        _busy = true;
        _menuOpen = false;
      });

      try {
        final outPath = await _cropFromPath(widget.imagePath!);
        if (!mounted) return;
        await _goToSaveItem(outPath);
      } catch (e) {
        debugPrint('Crop error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ประมวลผลรูปไม่สำเร็จ ลองอีกครั้ง')),
          );
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) {
      return;
    }

    setState(() {
      _busy = true;
      _menuOpen = false;
    });

    try {
      final photo = await c.takePicture();
      final outPath = await _cropFromPath(photo.path);

      if (!mounted) return;
      await _goToSaveItem(outPath);
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ถ่ายรูปไม่สำเร็จ ลองอีกครั้ง')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// คำนวณตำแหน่ง asset บนพื้นที่ preview ปัจจุบัน แล้ว crop+mask รูปที่ [path]
  ///
  /// โหมดกล้อง: รูปวางแบบ BoxFit.cover คงที่เสมอ จึงคำนวณ scale/offset
  /// อัตโนมัติใน _cropAndMask ได้เลย (เหมือนเดิม)
  ///
  /// โหมด gallery: ผู้ใช้ลาก/ซูมรูปเองผ่าน InteractiveViewer จึงต้องส่ง
  /// scale และตำแหน่งจริง ณ ตอนกด shutter เข้าไปแทน (overrideScale/Offset)
  Future<String> _cropFromPath(String path) {
    final frame = _guideSizeFor(_previewBox, _guide, _aspect);
    final assetRect = Rect.fromLTWH(
      (_previewBox.width - frame.width) / 2 + _kGuidePad,
      (_previewBox.height - frame.height) / 2 + _kGuidePad,
      frame.width - _kGuidePad * 2,
      frame.height - _kGuidePad * 2,
    );

    double? overrideScale;
    Offset? overrideOffset;

    if (widget.isGalleryMode) {
      // matrix ของ InteractiveViewer แทนการ scale+translate แบบ affine
      // (ไม่มี rotation) จึงดึง scale/translation ออกมาตรงๆ ได้
      final matrix = _transformController.value;
      final userScale = matrix.getMaxScaleOnAxis();
      final translation = matrix.getTranslation();

      overrideScale = (_coverScale ?? 1) * userScale;
      overrideOffset = Offset(translation.x, translation.y);
    }

    return compute(
      _cropAndMask,
      _CropRequest(
        path: path,
        boxWidth: _previewBox.width,
        boxHeight: _previewBox.height,
        assetRect: assetRect,
        overlayBytes: _overlayBytes,
        overrideScale: overrideScale,
        overrideOffset: overrideOffset,
      ),
    );
  }

  /// ไปหน้า Preview/Save item พร้อมรูปที่ crop แล้ว + guide type ที่ใช้ถ่าย
  /// รอผลกลับ: ถ้าหน้านั้น pop กลับมาพร้อม `true` (save สำเร็จแล้ว)
  /// ให้ปิดหน้านี้ต่อไปอีกที ถ้า pop มาเฉยๆ (กดลบ/ย้อนกลับ) ก็แก้ไขใหม่ได้เลย
  Future<void> _goToSaveItem(String path) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SaveItemScreen(imagePath: path, guideType: _guide),
      ),
    );

    if (saved == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A211C),
      body: SafeArea(
        child: Stack(
          children: [
            // ===== ชั้น 1: กล้อง/รูป gallery + guide (อยู่ในกรอบเดียวกัน) =====
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 160),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _previewBox = constraints.biggest;

                      if (widget.isGalleryMode && !_transformReady) {
                        // เลื่อนไปทำหลังเฟรมนี้ เพราะการ set ค่า
                        // TransformationController ระหว่าง build ไม่ปลอดภัย
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _initGalleryTransform());
                      }

                      final frame =
                          _guideSizeFor(_previewBox, _guide, _aspect);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPreview(),
                          Center(
                            child: IgnorePointer(
                              child: _GuideOverlay(
                                type: _guide,
                                size: frame,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ===== ชั้น 2: top bar =====
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: _TopBar(
                title: widget.isGalleryMode ? 'Adjust Photo' : 'Align Outfit',
                onBack: () => Navigator.maybePop(context),
              ),
            ),

            // ===== ชั้น 3: shutter =====
            Positioned(
              bottom: 76,
              left: 0,
              right: 0,
              child: Center(
                child: _ShutterButton(
                  busy: _busy,
                  onTap: _takePhoto,
                  // gallery mode ไม่ได้ "ถ่าย" แต่เป็นการยืนยันตำแหน่ง
                  icon: widget.isGalleryMode ? Icons.check : null,
                ),
              ),
            ),

            // ===== ชั้น 4: ปุ่ม Elements =====
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: _ElementsButton(
                  active: _menuOpen,
                  onTap: () => setState(() => _menuOpen = !_menuOpen),
                ),
              ),
            ),

            // ===== ชั้น 5: barrier กดข้างนอกเพื่อปิดเมนู =====
            if (_menuOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _menuOpen = false),
                ),
              ),

            // ===== ชั้น 6: เมนูเลือก guide มุมขวาบน =====
            Positioned(
              top: 56,
              right: 20,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1).animate(anim),
                    alignment: Alignment.topRight,
                    child: child,
                  ),
                ),
                child: _menuOpen
                    ? _GuideTypeMenu(
                        key: const ValueKey('menu'),
                        selected: _guide,
                        onSelected: _selectGuide,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// preview แบบ "cover" เต็มพื้นที่ (ไม่มีขอบดำ)
  /// - โหมด gallery: แสดงรูปที่เลือกไว้ ด้วย BoxFit.cover ตรงๆ
  /// - โหมดกล้อง: สมมติว่าแอปล็อก portrait จึงสลับ width/height ของ previewSize
  Widget _buildPreview() {
    if (widget.isGalleryMode) {
      final size = _galleryImageSize;

      // ระหว่างรอวัดขนาดรูป/พื้นที่ preview ให้โชว์แบบ cover เฉยๆ ไปก่อน
      if (!_transformReady || size == null) {
        return SizedBox.expand(
          child: Image.file(File(widget.imagePath!), fit: BoxFit.cover),
        );
      }

      // รูปถูกวางที่ขนาด cover-scale พอดี (coverScale * ขนาดจริง) แล้วให้
      // InteractiveViewer จัดการ pan/zoom เพิ่มเติมจากตรงนั้น
      return ClipRect(
        child: InteractiveViewer(
          transformationController: _transformController,
          constrained: false,
          minScale: 1,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: SizedBox(
            width: size.width * _coverScale!,
            height: size.height * _coverScale!,
            child: Image.file(
              File(widget.imagePath!),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xFF1E1B19),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ps = c.value.previewSize!;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ps.height,
          height: ps.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }
}

// ============================================================
// Crop + silhouette mask (รันใน isolate ผ่าน compute)
// ============================================================

class _CropRequest {
  const _CropRequest({
    required this.path,
    required this.boxWidth,
    required this.boxHeight,
    required this.assetRect,
    required this.overlayBytes,
    this.overrideScale,
    this.overrideOffset,
  });

  final String path;

  /// ขนาดพื้นที่ preview บนหน้าจอ
  final double boxWidth;
  final double boxHeight;

  /// พื้นที่ที่รูป asset ถูกวาด (พิกัดของพื้นที่ preview)
  final Rect assetRect;

  /// ไบต์ของ overlay PNG (null = ไม่ทำ mask แค่ crop สี่เหลี่ยม)
  final Uint8List? overlayBytes;

  /// ใช้แทนการคำนวณ BoxFit.cover อัตโนมัติ (โหมด gallery ที่ผู้ใช้
  /// ลาก/ซูมรูปเอง) — ถ้า null จะคำนวณจาก boxWidth/boxHeight เทียบกับ
  /// ขนาดรูปจริงเหมือนเดิม (โหมดกล้อง)
  final double? overrideScale;
  final Offset? overrideOffset;
}

/// 1) crop รูปตามตำแหน่ง asset  2) ตัดพื้นหลังทิ้งด้วยรูปทรง asset
/// ใช้ได้ทั้งรูปจากกล้องและรูปจาก gallery (path ใดก็ได้ที่เป็นไฟล์ภาพ)
/// คืน path ของไฟล์ PNG โปร่งใส
String _cropAndMask(_CropRequest r) {
  final bytes = File(r.path).readAsBytesSync();

  var photo = img.decodeImage(bytes);
  if (photo == null) throw Exception('decode photo failed');

  // หมุนรูปตาม EXIF ให้ตรงกับที่เห็นใน preview (ใช้ได้ทั้งรูปกล้องและ gallery)
  photo = img.bakeOrientation(photo);

  final iw = photo.width.toDouble();
  final ih = photo.height.toDouble();

  // ถ้ามี override (โหมด gallery ที่ผู้ใช้ลาก/ซูมเอง) ใช้ค่านั้นแทน
  // ไม่งั้นคำนวณจาก BoxFit.cover อัตโนมัติ (โหมดกล้อง)
  final scale = r.overrideScale ?? _max(r.boxWidth / iw, r.boxHeight / ih);
  final dx = r.overrideOffset?.dx ?? (r.boxWidth - iw * scale) / 2;
  final dy = r.overrideOffset?.dy ?? (r.boxHeight - ih * scale) / 2;

  var x = ((r.assetRect.left - dx) / scale).round();
  var y = ((r.assetRect.top - dy) / scale).round();
  var w = (r.assetRect.width / scale).round();
  var h = (r.assetRect.height / scale).round();

  x = x.clamp(0, photo.width - 1);
  y = y.clamp(0, photo.height - 1);
  w = w.clamp(1, photo.width - x);
  h = h.clamp(1, photo.height - y);

  final cropped = img.copyCrop(photo, x: x, y: y, width: w, height: h);

  // สร้าง mask จากรูปทรง overlay แล้วย่อ/ขยายให้เท่ากับรูปที่ crop
  img.Image? mask;
  if (r.overlayBytes != null) {
    final silhouette = _buildSilhouetteMask(r.overlayBytes!);
    if (silhouette != null) {
      mask = img.copyResize(
        silhouette,
        width: w,
        height: h,
        interpolation: img.Interpolation.linear,
      );
    }
  }

  // รวมรูป + mask เป็น RGBA (ที่อยู่นอกรูปทรงจะโปร่งใส)
  final out = img.Image(width: w, height: h, numChannels: 4);
  for (var yy = 0; yy < h; yy++) {
    for (var xx = 0; xx < w; xx++) {
      final p = cropped.getPixel(xx, yy);
      final a = mask == null ? 255 : mask.getPixel(xx, yy).r.toInt();
      out.setPixelRgba(xx, yy, p.r.toInt(), p.g.toInt(), p.b.toInt(), a);
    }
  }

  final outPath = r.path.replaceFirst(RegExp(r'\.\w+$'), '_masked.png');
  File(outPath).writeAsBytesSync(img.encodePng(out));
  return outPath;
}

/// สร้าง mask ขาว/ดำ ของ "พื้นที่ภายในรูปทรง" จาก overlay PNG
///
/// วิธี: flood fill จากขอบรูปผ่านพิกเซลโปร่งใส -> ทุกอย่างที่ไปไม่ถึง
/// (เส้นขอบ + ด้านในตัวเสื้อ) คือรูปทรง จึงใช้ได้ทั้ง asset ที่เป็น
/// silhouette ทึบ และ asset ที่เป็นแค่เส้นขอบ (ต้องเป็นเส้นปิดสนิท)
img.Image? _buildSilhouetteMask(Uint8List overlayBytes) {
  final overlay = img.decodeImage(overlayBytes);
  if (overlay == null || !overlay.hasAlpha) return null; // ไม่มี alpha = ทำ mask ไม่ได้

  final w = overlay.width;
  final h = overlay.height;

  // solid = พิกเซลที่มีเนื้อ (alpha สูง)
  final solid = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      solid[y * w + x] = overlay.getPixel(x, y).a >= 128 ? 1 : 0;
    }
  }

  // flood fill พื้นที่ "ข้างนอก" เริ่มจากทุกพิกเซลโปร่งใสที่ติดขอบรูป
  final outside = Uint8List(w * h);
  final queue = Int32List(w * h);
  var head = 0;
  var tail = 0;

  void push(int x, int y) {
    final i = y * w + x;
    if (solid[i] == 0 && outside[i] == 0) {
      outside[i] = 1;
      queue[tail++] = i;
    }
  }

  for (var x = 0; x < w; x++) {
    push(x, 0);
    push(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    push(0, y);
    push(w - 1, y);
  }

  while (head < tail) {
    final i = queue[head++];
    final x = i % w;
    final y = i ~/ w;
    if (x > 0) push(x - 1, y);
    if (x < w - 1) push(x + 1, y);
    if (y > 0) push(x, y - 1);
    if (y < h - 1) push(x, y + 1);
  }

  final mask = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final v = outside[y * w + x] == 1 ? 0 : 255;
      mask.setPixelRgb(x, y, v, v, v);
    }
  }
  return mask;
}

double _max(double a, double b) => a > b ? a : b;

// ============================================================
// Widgets
// ============================================================

/// กรอบ guide เส้นประ + รูป overlay ตามชนิดที่เลือก
class _GuideOverlay extends StatelessWidget {
  const _GuideOverlay({required this.type, required this.size});

  final GuideType type;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: Colors.white.withValues(alpha: 0.45),
          radius: 16,
        ),
        child: Padding(
          padding: const EdgeInsets.all(_kGuidePad),
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              type.assetPath,
              // กรอบมีสัดส่วนเท่ารูปอยู่แล้ว จึง fill ได้ตรงกับที่ใช้ crop/mask
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Icon(
                type.icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dash = 7,
    this.gap = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// เมนู "GUIDE TYPE" มุมขวาบน
class _GuideTypeMenu extends StatelessWidget {
  const _GuideTypeMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final GuideType selected;
  final ValueChanged<GuideType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE6E1D8),
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text(
                'GUIDE TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF8A847B),
                ),
              ),
            ),
            for (final type in GuideType.values)
              _MenuItem(
                type: type,
                selected: type == selected,
                onTap: () => onSelected(type),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final GuideType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3EFE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              type.icon,
              size: 18,
              color: selected
                  ? const Color(0xFF2A211C)
                  : const Color(0xFF8A847B),
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF2A211C)
                    : const Color(0xFF8A847B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.title});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap, required this.busy, this.icon});

  final VoidCallback onTap;
  final bool busy;

  /// ไอคอนกลางปุ่ม (ใช้ในโหมด gallery เพื่อสื่อว่าเป็นการ "ยืนยัน" ไม่ใช่ถ่ายรูป)
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: busy ? 0.6 : 1,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 4,
            ),
          ),
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF2A211C),
                  ),
                )
              : (icon == null
                  ? null
                  : Icon(icon, color: const Color(0xFF2A211C), size: 28)),
        ),
      ),
    );
  }
}

class _ElementsButton extends StatelessWidget {
  const _ElementsButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFC4B29C) : const Color(0xFF3A3532),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_outlined, size: 18, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Elements',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get recommend => 'แนะนำชุด';

  @override
  String get tryOutfit => 'ลองชุด';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get emptyCloset => 'ยังไม่มีเสื้อผ้าในตู้';

  @override
  String get emptyClosetHint => 'กดปุ่ม + เพื่อถ่ายรูปและเพิ่มชิ้นแรกของคุณ';

  @override
  String get saveOutfit => 'บันทึกชุด';

  @override
  String get outfitSaved => 'บันทึกชุดแล้ว';

  @override
  String get outfitAlreadySaved => 'ชุดนี้ถูกบันทึกไว้แล้ว';

  @override
  String get unableToRecommend => 'ยังจับคู่ชุดไม่ได้';

  @override
  String get unableToRecommendHint =>
      'ต้องมีเสื้อและกางเกงที่มีสไตล์เดียวกันและสีเข้ากันอย่างน้อยอย่างละ 1 ชิ้น';

  @override
  String get topsAndJackets => 'เสื้อและแจ็กเก็ต';

  @override
  String get bottoms => 'กางเกง';

  @override
  String get shoes => 'รองเท้า';

  @override
  String get casualWear => 'ชุดลำลอง';

  @override
  String get formalWear => 'ชุดทางการ';

  @override
  String noItemsInCategory(String category) {
    return 'ยังไม่มี$category';
  }

  @override
  String get addClothing => 'เพิ่มเสื้อผ้า';

  @override
  String get fromGallery => 'จากแกลเลอรี';

  @override
  String get takePhoto => 'ถ่ายรูป';

  @override
  String get saveItem => 'บันทึกเสื้อผ้า';

  @override
  String get style => 'สไตล์';

  @override
  String get selectCategory => 'เลือกประเภท';

  @override
  String get selectColor => 'เลือกสี';

  @override
  String get selectStyle => 'เลือกสไตล์';

  @override
  String get addToCloset => 'เพิ่มเข้าตู้เสื้อผ้า';

  @override
  String get pleaseEnterName => 'กรุณากรอกชื่อเสื้อผ้า';

  @override
  String get saveItemFailed => 'บันทึกไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get deleteCapturedPhotoHint =>
      'รูปที่ถ่ายไว้จะถูกลบและไม่สามารถกู้คืนได้';

  @override
  String get search => 'ค้นหา';

  @override
  String get name => 'ชื่อ';

  @override
  String get searchByName => 'ค้นหาจากชื่อ';

  @override
  String get category => 'ประเภท';

  @override
  String get allCategories => 'ทุกประเภท';

  @override
  String get color => 'สี';

  @override
  String get anyColor => 'สีอะไรก็ได้';

  @override
  String get formality => 'ความเป็นทางการ';

  @override
  String get allStyles => 'ทุกสไตล์';

  @override
  String get favoritesOnly => 'รายการโปรดเท่านั้น';

  @override
  String get searchResult => 'ผลการค้นหา';

  @override
  String get noClothesFound => 'ไม่พบเสื้อผ้า';

  @override
  String get noClothesFoundHint => 'ลองปรับตัวกรองของคุณ';

  @override
  String get item => 'ชิ้น';

  @override
  String get items => 'ชิ้น';

  @override
  String get found => 'ที่ค้นพบ';

  @override
  String get previewItem => 'ดูเสื้อผ้า';

  @override
  String get deleteItem => 'ลบเสื้อผ้าชิ้นนี้?';

  @override
  String get deleteItemHint => 'เสื้อผ้าชิ้นนี้จะถูกนำออกจากตู้ของคุณ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get delete => 'ลบ';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get languageSystem => 'ตามระบบ';

  @override
  String get languageEnglish => 'ภาษาอังกฤษ';

  @override
  String get languageThai => 'ภาษาไทย';

  @override
  String get fontSize => 'ขนาดตัวอักษร';

  @override
  String get fontSizeSystem => 'ตามระบบ';

  @override
  String get fontSizeSmall => 'เล็ก';

  @override
  String get fontSizeNormal => 'ปกติ';

  @override
  String get fontSizeLarge => 'ใหญ่';

  @override
  String get fontSizeExtraLarge => 'ใหญ่มาก';

  @override
  String get colorBlack => 'ดำ';

  @override
  String get colorWhite => 'ขาว';

  @override
  String get colorGray => 'เทา';

  @override
  String get colorSilver => 'เงิน';

  @override
  String get colorRed => 'แดง';

  @override
  String get colorBurgundy => 'แดงเบอร์กันดี';

  @override
  String get colorPink => 'ชมพู';

  @override
  String get colorCoral => 'คอรัล';

  @override
  String get colorOrange => 'ส้ม';

  @override
  String get colorPeach => 'พีช';

  @override
  String get colorYellow => 'เหลือง';

  @override
  String get colorGold => 'ทอง';

  @override
  String get colorGreen => 'เขียว';

  @override
  String get colorOlive => 'เขียวมะกอก';

  @override
  String get colorMint => 'มิ้นต์';

  @override
  String get colorTeal => 'เขียวน้ำทะเล';

  @override
  String get colorBlue => 'น้ำเงิน';

  @override
  String get colorSkyBlue => 'ฟ้า';

  @override
  String get colorNavy => 'กรมท่า';

  @override
  String get colorRoyalBlue => 'รอยัลบลู';

  @override
  String get colorPurple => 'ม่วง';

  @override
  String get colorLavender => 'ลาเวนเดอร์';

  @override
  String get colorBrown => 'น้ำตาล';

  @override
  String get colorTan => 'แทน';

  @override
  String get colorBeige => 'เบจ';

  @override
  String get colorCream => 'ครีม';

  @override
  String get colorKhaki => 'กากี';

  @override
  String get colorOther => 'อื่น ๆ';
}

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';

extension ItemCategoryLocalization on ItemCategory {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      ItemCategory.tops => l10n.topsAndJackets,
      ItemCategory.bottoms => l10n.bottoms,
      ItemCategory.shoes => l10n.shoes,
    };
  }
}

extension ItemStyleLocalization on ItemStyle {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      ItemStyle.casual => l10n.casualWear,
      ItemStyle.formal => l10n.formalWear,
    };
  }
}

extension ItemColorLocalization on ItemColor {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      ItemColor.black => l10n.colorBlack,
      ItemColor.white => l10n.colorWhite,
      ItemColor.gray => l10n.colorGray,
      ItemColor.silver => l10n.colorSilver,
      ItemColor.red => l10n.colorRed,
      ItemColor.burgundy => l10n.colorBurgundy,
      ItemColor.pink => l10n.colorPink,
      ItemColor.coral => l10n.colorCoral,
      ItemColor.orange => l10n.colorOrange,
      ItemColor.peach => l10n.colorPeach,
      ItemColor.yellow => l10n.colorYellow,
      ItemColor.gold => l10n.colorGold,
      ItemColor.green => l10n.colorGreen,
      ItemColor.olive => l10n.colorOlive,
      ItemColor.mint => l10n.colorMint,
      ItemColor.teal => l10n.colorTeal,
      ItemColor.blue => l10n.colorBlue,
      ItemColor.skyBlue => l10n.colorSkyBlue,
      ItemColor.navy => l10n.colorNavy,
      ItemColor.royalBlue => l10n.colorRoyalBlue,
      ItemColor.purple => l10n.colorPurple,
      ItemColor.lavender => l10n.colorLavender,
      ItemColor.brown => l10n.colorBrown,
      ItemColor.tan => l10n.colorTan,
      ItemColor.beige => l10n.colorBeige,
      ItemColor.cream => l10n.colorCream,
      ItemColor.khaki => l10n.colorKhaki,
      ItemColor.other => l10n.colorOther,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/app_language.dart';
import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _fontLabel(AppLocalizations l10n, FontSizeOption option) {
    return switch (option) {
      FontSizeOption.system => l10n.fontSizeSystem,
      FontSizeOption.small => l10n.fontSizeSmall,
      FontSizeOption.normal => l10n.fontSizeNormal,
      FontSizeOption.large => l10n.fontSizeLarge,
      FontSizeOption.extraLarge => l10n.fontSizeExtraLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Language setting card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                    ),

                    // RadioGroup จัดการค่าที่เลือกแทน groupValue/onChanged
                    // ของ RadioListTile (ถูก deprecated ตั้งแต่ Flutter 3.32)
                    RadioGroup<AppLanguage>(
                      groupValue: widget.selectedLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          widget.onLanguageChanged(value);
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<AppLanguage>(
                            value: AppLanguage.system,
                            title: Text(l10n.languageSystem),
                          ),
                          RadioListTile<AppLanguage>(
                            value: AppLanguage.english,
                            title: Text(l10n.languageEnglish),
                          ),
                          RadioListTile<AppLanguage>(
                            value: AppLanguage.thai,
                            title: Text(l10n.languageThai),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Font size setting card
              // ฟัง AppSettings เพื่อให้ตัวเลือกที่เลือกอยู่อัปเดตทันที
              ListenableBuilder(
                listenable: AppSettings.instance,
                builder: (context, _) {
                  final settings = AppSettings.instance;

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.format_size),
                          title: Text(l10n.fontSize),
                        ),

                        RadioGroup<FontSizeOption>(
                          groupValue: settings.fontSize,
                          onChanged: (value) {
                            if (value != null) {
                              settings.setFontSize(value);
                            }
                          },
                          child: Column(
                            children: [
                              for (final option in FontSizeOption.values)
                                RadioListTile<FontSizeOption>(
                                  value: option,
                                  title: Text(_fontLabel(l10n, option)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
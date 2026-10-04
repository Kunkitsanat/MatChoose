import 'package:flutter/material.dart';
import 'package:matchoose/models/app_language.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),

              SizedBox(height: 30,),

              // Language setting card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                    ),

                    RadioListTile<AppLanguage>(
                      value: AppLanguage.system,
                      groupValue: widget.selectedLanguage,
                      title: const Text('System Default'),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onLanguageChanged(value);
                        }
                      },
                    ),

                    RadioListTile<AppLanguage>(
                      value: AppLanguage.english,
                      groupValue: widget.selectedLanguage,
                      title: const Text('English'),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onLanguageChanged(value);
                        }
                      },
                    ),

                    RadioListTile<AppLanguage>(
                      value: AppLanguage.thai,
                      groupValue: widget.selectedLanguage,
                      title: const Text('ภาษาไทย'),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onLanguageChanged(value);
                        }
                      },
                    ),

                  ],
                ),
              ),

              SizedBox(height: 10,),
              
              // Font size setting card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.format_size),
                      title: Text('Font size'),
                    ),

                    // ใส่ตั้งค่าขนาดฟอนต์
                  ]
                )
              ),

            ],
          ),
        ),
      )
    );
  }
}
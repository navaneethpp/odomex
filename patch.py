import glob

patch = """
  @override
  bool getAutoFillCurrentOdometer() => true;

  @override
  Future<void> saveAutoFillCurrentOdometer(bool enabled) async {}
"""

files = glob.glob('test/**/*.dart', recursive=True)
for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    if 'implements AppSettingsLocalDataSource' in content:
        if 'getAutoFillCurrentOdometer' not in content:
            search_str = "Future<void> saveNotificationSettings("
            if search_str in content:
                idx = content.find(search_str)
                brace_idx = content.find("}", idx)
                if brace_idx != -1:
                    new_content = content[:brace_idx + 1] + patch + content[brace_idx + 1:]
                    with open(file, 'w') as f:
                        f.write(new_content)
                    print(f"Patched {file}")

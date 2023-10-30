mixin settings_mixin {
  //Blah blah blah. Save file. Read file.
  SettingsSingleton settings = SettingsSingleton();
}

//Since this is a Singleton it's accessible from the whole app at the same time.
//Everything will be synced nicely!
class SettingsSingleton {
  int _testValue = 0;
  static final SettingsSingleton _settingsSingleton =
      SettingsSingleton._internal();

  factory SettingsSingleton() {
    return _settingsSingleton;
  }
  SettingsSingleton._internal();

  int getTestValue() {
    return _testValue;
  }

  void setTestValue(tV) {
    _testValue = tV;
  }
}

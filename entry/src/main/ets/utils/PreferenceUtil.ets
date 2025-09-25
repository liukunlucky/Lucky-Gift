import preferences from '@ohos.data.preferences';

// Preference工具类，用于管理应用配置
export class PreferenceUtil {
  private static instance: PreferenceUtil;
  private preferencesStore: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'app_preferences';

  private constructor() {}

  public static getInstance(): PreferenceUtil {
    if (!PreferenceUtil.instance) {
      PreferenceUtil.instance = new PreferenceUtil();
    }
    return PreferenceUtil.instance;
  }

  // 初始化preference存储
  public async init(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (error) {
      console.error('初始化Preference失败:', error);
      throw new Error('初始化Preference失败');
    }
  }

  // 设置布尔值
  public async setBool(key: string, value: boolean): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      await this.preferencesStore.put(key, value);
      await this.preferencesStore.flush();
    } catch (error) {
      console.error(`设置布尔值失败 ${key}:`, error);
      throw new Error(`设置布尔值失败 ${key}`);
    }
  }

  // 获取布尔值
  public async getBool(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      return await this.preferencesStore.get(key, defaultValue) as boolean;
    } catch (error) {
      console.error(`获取布尔值失败 ${key}:`, error);
      return defaultValue;
    }
  }

  // 设置字符串值
  public async setString(key: string, value: string): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      await this.preferencesStore.put(key, value);
      await this.preferencesStore.flush();
    } catch (error) {
      console.error(`设置字符串值失败 ${key}:`, error);
      throw new Error(`设置字符串值失败 ${key}`);
    }
  }

  // 获取字符串值
  public async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      return await this.preferencesStore.get(key, defaultValue) as string;
    } catch (error) {
      console.error(`获取字符串值失败 ${key}:`, error);
      return defaultValue;
    }
  }

  // 设置数字值
  public async setNumber(key: string, value: number): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      await this.preferencesStore.put(key, value);
      await this.preferencesStore.flush();
    } catch (error) {
      console.error(`设置数字值失败 ${key}:`, error);
      throw new Error(`设置数字值失败 ${key}`);
    }
  }

  // 获取数字值
  public async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      return await this.preferencesStore.get(key, defaultValue) as number;
    } catch (error) {
      console.error(`获取数字值失败 ${key}:`, error);
      return defaultValue;
    }
  }

  // 删除指定键
  public async remove(key: string): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      await this.preferencesStore.delete(key);
      await this.preferencesStore.flush();
    } catch (error) {
      console.error(`删除键失败 ${key}:`, error);
      throw new Error(`删除键失败 ${key}`);
    }
  }

  // 清空所有数据
  public async clear(): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      await this.preferencesStore.clear();
      await this.preferencesStore.flush();
    } catch (error) {
      console.error('清空Preference失败:', error);
      throw new Error('清空Preference失败');
    }
  }

  // 检查键是否存在
  public async hasKey(key: string): Promise<boolean> {
    if (!this.preferencesStore) {
      throw new Error('Preference未初始化');
    }
    try {
      return await this.preferencesStore.has(key);
    } catch (error) {
      console.error(`检查键存在失败 ${key}:`, error);
      return false;
    }
  }
}

// 常用的preference键名常量
export class PreferenceKeys {
  static readonly SHOW_MOCK_STORY: string = 'show_mock_story'; // 是否显示mock故事
  static readonly THEME_MODE: string = 'theme_mode'; // 主题模式
  static readonly NOTIFICATION_ENABLED: string = 'notification_enabled'; // 通知开关
  static readonly REMINDER_ENABLED: string = 'reminder_enabled'; // 提醒开关
}
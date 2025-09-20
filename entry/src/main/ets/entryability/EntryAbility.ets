import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { font, window } from '@kit.ArkUI';
import { WindowAbility } from './WindowAbility';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { InspirationDataInitializer } from '../database/InspirationDataInitializer';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    WindowAbility.getInstance().initContext(this.context);
    
    // 初始化数据库
    this.initDatabase();
  }


  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainTabsPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      font.registerFont({
        familyName: 'cjzj',
        familySrc: $rawfile('font1.ttf')
      })
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  
  // 初始化数据库
  private async initDatabase(): Promise<void> {
    try {
      hilog.info(DOMAIN, 'testTag', '数据库初始化成功');
      hilog.info(DOMAIN, 'testTag', '开始初始化数据...');
      
      // 初始化数据库
      const dbManager = new NewDatabaseManager();
      await dbManager.initDatabase(this.context);
      
      // 初始化灵感数据
      const dataInitializer = new InspirationDataInitializer();
      await dataInitializer.initializeAllData();
      
      hilog.info(DOMAIN, 'testTag', '数据库初始化完成');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', '数据库初始化失败: %{public}s', JSON.stringify(error));
    }
  }
}
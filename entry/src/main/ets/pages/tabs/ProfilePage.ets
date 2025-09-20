import router from '@ohos.router';
import { Contact, Inspiration, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { InspirationDAO } from '../../database/InspirationDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ReminderDAO } from '../../database/ReminderDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import bundleManager from '@ohos.bundle.bundleManager';

// 菜单项接口定义
interface MenuItem {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  color: string;
  count?: number;
}

interface DataMenuItem {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  color: string;
}

interface OtherMenuItem {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  color: string;
}

interface ExportMetadata {
  totalContacts: number;
  totalEvents: number;
  totalSpent: number;
}

interface ExportData {
  version: string;
  exportDate: string;
  contacts: Contact[];
  giftEvents: GiftEvent[];
  inspirations: Inspiration[];
  metadata: ExportMetadata;
}

@Component
export struct ProfilePage {
  @State contacts: Contact[] = [];
  @State favoriteInspirations: Inspiration[] = [];
  @State totalGiftEvents: number = 0;
  @State totalSpent: number = 0;
  @State giveEvents: number = 0;
  @State receiveEvents: number = 0;
  @State giveSpent: number = 0;
  @State receiveSpent: number = 0;
  @State isLoading: boolean = true;
  @State showExportDialog: boolean = false;
  @State showImportDialog: boolean = false;
  @State exportProgress: number = 0;
  @State importProgress: number = 0;
  @State userLevel: string = 'LV1';
  @State showAboutSheet: boolean = false;
  @State showFeedbackSheet: boolean = false;
  @State feedbackText: string = '';
  @State versionName: string = '';

  private dbManager: NewDatabaseManager | null = null;
  private contactDAO: ContactDAO | null = null;
  private inspirationDAO: InspirationDAO | null = null;
  private giftEventDAO: GiftEventDAO | null = null;
  private reminderDAO: ReminderDAO | null = null;
  @State reminderCount: number = 0;
  @StorageProp('refreshProfilePage') @Watch('onRefreshProfile') refreshProfile: number = -1;


  // 功能菜单配置
  private menuItems: MenuItem[] = [
    {
      id: 'relationships',
      title: '我的关系网络',
      description: '管理联系人和重要关系',
      icon: $r('app.media.icon_rq'),
      color: '#4CAF50',
      count: 0
    },
    {
      id: 'favorites',
      title: '我的收藏',
      description: '收藏的灵感和创意',
      icon: $r('app.media.icon_ax'),
      color: '#E91E63',
      count: 0
    },
    {
      id: 'reminders',
      title: '礼物提醒',
      description: '重要日期提醒设置',
      icon: $r('app.media.icon_ld'),
      color: '#FF9800',
      count: 0
    },
    {
      id: 'statistics',
      title: '礼物统计',
      description: '查看收送礼数据分析',
      icon: $r('app.media.icon_tj'),
      color: '#2196F3',
      count: 0
    }
  ];
  
  // 数据管理菜单
  private dataMenuItems: DataMenuItem[] = [
    {
      id: 'export',
      title: '导出数据',
      description: '备份所有礼物记录',
      icon: $r('app.media.icon_dc'),
      color: '#9C27B0'
    },
    {
      id: 'import',
      title: '导入数据',
      description: '恢复之前的备份',
      icon: $r('app.media.icon_dr'),
      color: '#607D8B'
    },
    {
      id: 'clear',
      title: '清空数据',
      description: '删除所有本地数据',
      icon: $r('app.media.icon_delete'),
      color: '#F44336'
    }
  ];

  // 其他菜单
  private otherMenuItems: OtherMenuItem[] = [
    {
      id: 'check_update',
      title: '检查更新',
      description: '查看是否有新版本',
      icon: $r('app.media.ic_update'),
      color: '#4CAF50'
    },
    {
      id: 'feedback',
      title: '问题反馈',
      description: '遇到问题？告诉我们',
      icon: $r('app.media.ic_feedback'),
      color: '#FF9800'
    },
    {
      id: 'rate',
      title: '给个好评',
      description: '为应用评分支持',
      icon: $r('app.media.ic_star'),
      color: '#E91E63'
    },
    {
      id: 'about',
      title: '关于应用',
      description: '版本信息和开发者',
      icon: $r('app.media.ic_info'),
      color: '#2196F3'
    }
  ];

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    this.dbManager = new NewDatabaseManager();
    await this.dbManager.initDatabase(context);
    
    // 初始化DAO
    this.contactDAO = new ContactDAO(this.dbManager);
    this.inspirationDAO = new InspirationDAO(this.dbManager);
    this.giftEventDAO = new GiftEventDAO(this.dbManager);
    this.reminderDAO = new ReminderDAO(this.dbManager);
    
    this.loadData();
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
  }

  onRefreshProfile() {
    if (this.refreshProfile >= 0) {
      this.loadData();
      AppStorage.setOrCreate('refreshProfile', -1);
    }
  }

  async loadData() {
    try {
      this.isLoading = true;
      
      if (!this.contactDAO || !this.inspirationDAO || !this.giftEventDAO || !this.reminderDAO) {
        console.error('数据库未初始化');
        return;
      }
      
      // 加载联系人
      this.contacts = await this.contactDAO.getAllContacts();
      
      // 加载收藏的灵感
      this.favoriteInspirations = await this.inspirationDAO.getFavoriteInspirations();
      
      // 加载提醒数据
      const reminders = await this.reminderDAO.getAllReminders();
      this.reminderCount = reminders.length;
      
      // 加载统计数据
      const stats = await this.giftEventDAO.getGiftEventStats();
      this.totalGiftEvents = stats.totalEvents;
      this.totalSpent = stats.totalSpent;
      
      // 加载分类统计数据
      const typeStats = await this.giftEventDAO.getGiftEventTypeStats();
      this.giveEvents = typeStats.giveEvents;
      this.receiveEvents = typeStats.receiveEvents;
      this.giveSpent = typeStats.giveSpent;
      this.receiveSpent = typeStats.receiveSpent;
      
      // 更新菜单计数
      this.updateMenuCounts();
    } catch (error) {
      console.error('加载个人数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 更新菜单计数
  updateMenuCounts() {
    this.menuItems.forEach(item => {
      switch (item.id) {
        case 'relationships':
          item.count = this.contacts.length;
          break;
        case 'favorites':
          item.count = this.favoriteInspirations.length;
          break;
        case 'reminders':
          // 使用实际的数据库提醒记录数量
          item.count = this.reminderCount;
          break;
        case 'statistics':
          item.count = this.totalGiftEvents;
          break;
      }
    });
  }

  // 导航到功能页面
  navigateToFeature(featureId: string) {
    switch (featureId) {
      case 'relationships':
        router.pushUrl({
          url: 'pages/profile/RelationshipNetworkPage'
        }).catch((error: Error) => {
          console.error('导航到关系网络页面失败:', error);
        });
        break;
      case 'favorites':
        router.pushUrl({
          url: 'pages/profile/FavoritesPage'
        });
        break;
      case 'reminders':
        router.pushUrl({
          url: 'pages/profile/GiftReminderPage'
        }).catch((error: Error) => {
          console.error('导航到礼物提醒页面失败:', error);
        });
        break;
      case 'statistics':
        router.pushUrl({
          url: 'pages/profile/GiftStatisticsPage'
        }).catch((error: Error) => {
          console.error('导航到送礼统计页面失败:', error);
        });
        break;
    }
  }

  navigateToFavorites() {
    router.pushUrl({
      url: 'pages/profile/FavoritesPage'
    });
  }

  // 处理数据管理操作
  handleDataOperation(operationId: string) {
    switch (operationId) {
      case 'export':
        this.showExportDialog = true;
        break;
      case 'import':
        this.showImportDialog = true;
        break;
      case 'clear':
        this.showClearDataConfirmation();
        break;
    }
  }

  // 处理数据菜单点击
  handleDataMenuClick(itemId: string) {
    this.handleDataOperation(itemId);
  }

  // 处理其他菜单点击
  handleOtherMenuClick(itemId: string) {
    switch (itemId) {
      case 'check_update':
        this.checkForUpdates();
        break;
      case 'feedback':
        this.openFeedback();
        break;
      case 'rate':
        this.showRateDialog();
        break;
      case 'about':
        this.showAboutDialog();
        break;
    }
  }

  // 检查更新
  private checkForUpdates() {
    // 这里可以实现检查更新的逻辑
    AlertDialog.show({
      title: '检查更新',
      message: '当前已是最新版本',
      primaryButton: {
        value: '确定',
        action: () => {
        }
      }
    });
    console.info('检查更新功能');
  }

  // 打开反馈
  private openFeedback() {
    // 这里可以实现反馈功能
    this.showFeedbackSheet = true;
    console.info('问题反馈功能');
  }

  // 显示评分对话框
  private showRateDialog() {
    // 显示感谢toast
    promptAction.showToast({
      message: '感谢您的支持～',
      duration: 2000
    });
  }

  // 显示关于对话框
  private showAboutDialog() {
    // 这里可以实现关于应用的对话框
    this.showAboutSheet = true;
    console.info('关于应用功能');
  }

  // 导出数据
  async exportData() {
    try {
      this.exportProgress = 0;
      
      // 收集所有数据
      if (!this.contactDAO || !this.giftEventDAO || !this.inspirationDAO) {
        console.error('数据库未初始化，无法导出数据');
        return;
      }
      
      const exportData: ExportData = {
        version: '1.0',
        exportDate: new Date().toISOString(),
        contacts: await this.contactDAO.getAllContacts(),
        giftEvents: await this.giftEventDAO.getAllGiftEvents(),
        inspirations: await this.inspirationDAO.getFavoriteInspirations(),
        metadata: {
          totalContacts: this.contacts.length,
          totalEvents: this.totalGiftEvents,
          totalSpent: this.totalSpent
        } as ExportMetadata
      };
      
      this.exportProgress = 50;
      
      // 生成文件名
      const timestamp = new Date().toISOString().slice(0, 10);
      const fileName = `lucky_gift_backup_${timestamp}.json`;
      
      // 将数据转换为JSON字符串
      const jsonData = JSON.stringify(exportData, null, 2);
      
      this.exportProgress = 80;
      
      // 这里应该调用文件保存API，由于HarmonyOS的文件API限制，
      // 实际实现可能需要使用picker.save()或其他方式
      console.log('导出数据:', fileName, jsonData.length, '字符');
      
      this.exportProgress = 100;
      
      // 显示成功消息
      setTimeout(() => {
        this.showExportDialog = false;
        this.exportProgress = 0;
      }, 1000);
      
    } catch (error) {
      console.error('导出数据失败:', error);
      this.showExportDialog = false;
      this.exportProgress = 0;
    }
  }

  // 导入数据
  async importData() {
    try {
      this.importProgress = 0;
      
      // 这里应该使用文件选择器选择备份文件
      // 由于API限制，这里只是示例代码
      
      this.importProgress = 30;
      
      // 解析JSON数据
      // const importData = JSON.parse(fileContent);
      
      this.importProgress = 60;
      
      // 导入联系人
      // await this.contactDAO.importContacts(importData.contacts);
      
      // 导入礼物事件
      // await this.giftEventDAO.importGiftEvents(importData.giftEvents);
      
      // 导入收藏的灵感
      // await this.inspirationDAO.importFavorites(importData.inspirations);
      
      this.importProgress = 90;
      
      // 重新加载数据
      await this.loadData();
      
      this.importProgress = 100;
      
      setTimeout(() => {
        this.showImportDialog = false;
        this.importProgress = 0;
      }, 1000);
      
    } catch (error) {
      console.error('导入数据失败:', error);
      this.showImportDialog = false;
      this.importProgress = 0;
    }
  }

  // 显示清空数据确认对话框
  showClearDataConfirmation() {
    AlertDialog.show({
      title: '确认清空数据',
      message: '此操作将删除所有本地数据，包括联系人、礼物记录和收藏的灵感。此操作不可恢复，请确认是否继续？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确认清空',
        fontColor: '#FF4444',
        action: () => {
          this.clearAllData();
        }
      }
    });
  }

  // 清空所有数据
  async clearAllData() {
    try {
      if (!this.dbManager) {
        console.error('数据库未初始化，无法清空数据');
        return;
      }
      
      // 清空所有表的数据
      await this.dbManager.clearAllData();
      
      // 重新加载数据
      await this.loadData();
      
      // 显示成功消息
      AlertDialog.show({
        title: '清空完成',
        message: '所有数据已成功清空。',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    } catch (error) {
      console.error('清空数据失败:', error);
      AlertDialog.show({
        title: '清空失败',
        message: '清空数据时发生错误，请重试。',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      });
    }
  }

  // 格式化金额
  formatAmount(amount: number): string {
    if (amount >= 10000) {
      return `${(amount / 10000).toFixed(1)}万`;
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(1)}k`;
    }
    return amount.toString();
  }

  build() {
    Column() {
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 顶部个人信息卡片
            Column() {
              Row() {
                // 头像
                Image($r('app.media.ic_mine'))
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .margin({ right: 16 })
                  .backgroundColor('#FFFFFF')
                  .padding(10)
                  .shadow({
                    radius: 4,
                    color: 'rgba(0,0,0,0.1)',
                    offsetX: 0,
                    offsetY: 2
                  })
                
                Column() {
                  Text('我的礼物智库')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                  
                  Text('记录每一份心意')
                    .fontSize(14)
                    .fontColor('#FFE0D6')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 16 })
                
                Blank()
                Text(this.userLevel)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.brand_color'))
                  .backgroundColor('#FFFFFF')
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                  .borderRadius(12)
                  .shadow({
                    radius: 2,
                    color: 'rgba(0,0,0,0.1)',
                    offsetX: 0,
                    offsetY: 1
                  })
              }
              .width('100%')
              .margin({ bottom: 20 })
              
              // 统计数据
              Column({ space: 16 }) {
                // 第一行：联系人和总记录
                Row() {
                  Column() {
                    Text(this.contacts.length.toString())
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('联系人')
                      .fontSize(12)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text(this.totalGiftEvents.toString())
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('礼物记录')
                      .fontSize(12)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                
                // 第二行：送礼和收礼统计
                Row() {
                  Column() {
                    Text(this.giveEvents.toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('送礼次数')
                      .fontSize(11)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text(this.receiveEvents.toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('收礼次数')
                      .fontSize(11)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text(`¥${this.formatAmount(this.giveSpent)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('送礼花费')
                      .fontSize(11)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text(`¥${this.formatAmount(this.receiveSpent)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    
                    Text('收礼价值')
                      .fontSize(11)
                      .fontColor('#FFE0D6')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
            }
            .width('90%')
            .padding({left: 20, right: 20, bottom: 20, top: 40})
            .backgroundColor('#FF6B35')
            .borderRadius(20)
            .margin({ top: 20, bottom: 16 })

            // 功能菜单
            Column() {
              // 功能设置卡片（包含标题）
              Column() {
                // 分组标题
                Text('我的功能')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 16, top: 16, bottom: 8 })

                ForEach(this.menuItems, (item: MenuItem, index: number) => {
                  Column() {
                    Row() {
                      Image(item.icon)
                        .width(20)
                        .height(20)
                        .fillColor($r('app.color.primary_text_color'))
                        .margin({ right: 12 })

                      Column() {
                        Text(item.title)
                          .fontSize(16)
                          .fontColor($r('app.color.primary_text_color'))
                          .fontWeight(FontWeight.Medium)

                        Text(item.description)
                          .fontSize(14)
                          .fontColor($r('app.color.secondary_text_color'))
                          .margin({ top: 2 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Row() {
                        if (item.count !== undefined) {
                          Text(item.count.toString())
                            .fontSize(14)
                            .fontColor($r('app.color.secondary_text_color'))
                            .margin({ right: 8 })
                        }
                        
                        Image($r('app.media.ic_arrow_right'))
                          .width(20)
                          .height(20)
                          .fillColor($r('app.color.tertiary_text_color'))
                      }
                    }
                    .width('100%')
                    .padding({
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16
                    })
                    .onClick(() => {
                      this.navigateToFeature(item.id);
                    })

                    // 分隔线（最后一项不显示）
                    if (index < this.menuItems.length - 1) {
                      Divider()
                        .color($r('app.color.divider_color'))
                        .strokeWidth(0.5)
                        .margin({ left: 48, right: 16 })
                    }
                  }
                }, (item: MenuItem) => item.id)
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: $r('app.color.shadow_color'),
                offsetX: 0,
                offsetY: 1
              })
            }
            .width('100%')
            .margin({ top: 24 })
            .padding({ left: 24, right: 24 })

            // 数据管理
            Column() {
              // 数据管理卡片（包含标题）
              Column() {
                // 分组标题
                Text('数据管理')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 16, top: 16, bottom: 8 })

                ForEach(this.dataMenuItems, (item: DataMenuItem, index: number) => {
                  Column() {
                    Row() {
                      Image(item.icon)
                        .width(20)
                        .height(20)
                        .fillColor($r('app.color.primary_text_color'))
                        .margin({ right: 12 })

                      Column() {
                        Text(item.title)
                          .fontSize(16)
                          .fontColor($r('app.color.primary_text_color'))
                          .fontWeight(FontWeight.Medium)

                        Text(item.description)
                          .fontSize(14)
                          .fontColor($r('app.color.secondary_text_color'))
                          .margin({ top: 2 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Row() {
                        Image($r('app.media.ic_arrow_right'))
                          .width(20)
                          .height(20)
                          .fillColor($r('app.color.tertiary_text_color'))
                      }
                    }
                    .width('100%')
                    .padding({
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16
                    })
                    .onClick(() => {
                       this.handleDataMenuClick(item.id);
                     })

                    // 分隔线（最后一项不显示）
                    if (index < this.dataMenuItems.length - 1) {
                      Divider()
                        .color($r('app.color.divider_color'))
                        .strokeWidth(0.5)
                        .margin({ left: 48, right: 16 })
                    }
                  }
                }, (item: DataMenuItem) => item.id)
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: $r('app.color.shadow_color'),
                offsetX: 0,
                offsetY: 1
              })
            }
            .width('100%')
            .margin({ top: 24 })
            .padding({ left: 24, right: 24 })
            .visibility(Visibility.None)
            .bindSheet($$this.showImportDialog, this.buildImportDialog(), {
              height: 300,
              dragBar: true
            })

            // 其他
            Column() {
              // 其他设置卡片（包含标题）
              Column() {
                // 分组标题
                Text('设置')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_text_color'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 16, top: 16, bottom: 8 })

                ForEach(this.otherMenuItems, (item: OtherMenuItem, index: number) => {
                  Column() {
                    Row() {
                      Image(item.icon)
                        .width(20)
                        .height(20)
                        .fillColor($r('app.color.primary_text_color'))
                        .margin({ right: 12 })

                      Column() {
                        Text(item.title)
                          .fontSize(16)
                          .fontColor($r('app.color.primary_text_color'))
                          .fontWeight(FontWeight.Medium)

                        Text(item.description)
                          .fontSize(14)
                          .fontColor($r('app.color.secondary_text_color'))
                          .margin({ top: 2 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Row() {
                        Image($r('app.media.ic_arrow_right'))
                          .width(20)
                          .height(20)
                          .fillColor($r('app.color.tertiary_text_color'))
                      }
                    }
                    .width('100%')
                    .padding({
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16
                    })
                    .onClick(() => {
                      this.handleOtherMenuClick(item.id);
                    })

                    // 分隔线（最后一项不显示）
                    if (index < this.otherMenuItems.length - 1) {
                      Divider()
                        .color($r('app.color.divider_color'))
                        .strokeWidth(0.5)
                        .margin({ left: 48, right: 16 })
                    }
                  }
                }, (item: OtherMenuItem) => item.id)
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background_color'))
              .borderRadius(12)
              .shadow({
                radius: 2,
                color: $r('app.color.shadow_color'),
                offsetX: 0,
                offsetY: 1
              })
              .bindSheet($$this.showAboutSheet, this.AboutSheet(), {
                height: 400,
                dragBar: true,
                showClose: false,
                backgroundColor: $r('app.color.surface_color'),
                onDisappear: () => {
                  // 移除状态重置，避免与深色模式切换冲突
                }
              })
            }
            .width('100%')
            .margin({ top: 24, bottom: 24 })
            .padding({ left: 24, right: 24 })
            .bindSheet($$this.showFeedbackSheet, this.FeedbackSheet(), {
              height: 350,
              dragBar: true,
              showClose: false,
              backgroundColor: $r('app.color.surface_color'),
              onDisappear: () => {
                // 移除状态重置，避免与深色模式切换冲突
              }
            })

          }
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
    .bindSheet($$this.showExportDialog, this.buildExportDialog(), {
      height: 300,
      dragBar: true
    })

  }

  @Builder
  buildExportDialog() {
    Column() {
      Text('导出数据')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 24 })
      
      if (this.exportProgress === 0) {
        Column() {
          Text('即将导出以下数据：')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ bottom: 16 })
          
          Column() {
            Text(`• ${this.contacts.length} 个联系人`)
              .fontSize(14)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 4 })
            
            Text(`• ${this.totalGiftEvents} 条礼物记录`)
              .fontSize(14)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 4 })
            
            Text(`• ${this.favoriteInspirations.length} 个收藏的灵感`)
              .fontSize(14)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .margin({ bottom: 24 })
          
          Row() {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#F0F0F0')
              .fontColor('#333333')
              .borderRadius(22)
              .margin({ right: 8 })
              .onClick(() => {
                this.showExportDialog = false;
              })
            
            Button('开始导出')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#FF6B35')
              .fontColor(Color.White)
              .borderRadius(22)
              .margin({ left: 8 })
              .onClick(() => {
                this.exportData();
              })
          }
          .width('100%')
        }
      } else {
        Column() {
          Text('正在导出数据...')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ bottom: 16 })
          
          Progress({ value: this.exportProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .color('#FF6B35')
            .backgroundColor('#F0F0F0')
            .margin({ bottom: 16 })
          
          Text(`${this.exportProgress}%`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(24)
  }

  @Builder
  buildImportDialog() {
    Column() {
      Text('导入数据')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 24 })
      
      if (this.importProgress === 0) {
        Column() {
          Text('选择要导入的备份文件')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ bottom: 16 })
          
          Text('⚠️ 导入数据将覆盖当前所有数据，请确保已备份重要信息。')
            .fontSize(12)
            .fontColor('#FF6B35')
            .backgroundColor('#FFF0ED')
            .padding(12)
            .borderRadius(8)
            .margin({ bottom: 24 })
          
          Row() {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#F0F0F0')
              .fontColor('#333333')
              .borderRadius(22)
              .margin({ right: 8 })
              .onClick(() => {
                this.showImportDialog = false;
              })
            
            Button('选择文件')
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#FF6B35')
              .fontColor(Color.White)
              .borderRadius(22)
              .margin({ left: 8 })
              .onClick(() => {
                this.importData();
              })
          }
          .width('100%')
        }
      } else {
        Column() {
          Text('正在导入数据...')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ bottom: 16 })
          
          Progress({ value: this.importProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .color('#FF6B35')
            .backgroundColor('#F0F0F0')
            .margin({ bottom: 16 })
          
          Text(`${this.importProgress}%`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(24)
  }

  @Builder
  FeedbackSheet() {
    Column() {
      // Sheet标题
      Text('问题反馈')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 输入提示
      Text('请描述您遇到的问题或建议')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)

      // 输入框
      TextArea({
        placeholder: '请输入您的问题或建议...',
        text: this.feedbackText
      })
        .width('100%')
        .height(120)
        .fontSize(14)
        .fontColor($r('app.color.primary_text_color'))
        .backgroundColor($r('app.color.input_background_color'))
        .borderRadius(8)
        .padding(12)
        .maxLength(100)
        .onChange((value: string) => {
          this.feedbackText = value;
        })
        .margin({ bottom: 8 })

      // 字数统计
      Text(`${this.feedbackText.length}/100`)
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .alignSelf(ItemAlign.End)
        .margin({ bottom: 24 })

      // 提交按钮
      Button('提交反馈')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(8)
        .enabled(this.feedbackText.trim().length > 0)
        .opacity(this.feedbackText.trim().length > 0 ? 1 : 0.5)
        .onClick(() => {
          if (this.feedbackText.trim().length > 0) {
            promptAction.showToast({
              message: '感谢您的反馈',
              duration: 2000
            });
            this.feedbackText = '';
            this.showFeedbackSheet = false;
          }
        })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  AboutSheet() {
    Column() {
      // Sheet标题
      Text('关于App')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 应用图标
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ bottom: 16 })

      // 应用信息
      Column() {
        Text('送什么礼')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })

        Text($r('app.string.version', '版本号', this.versionName))
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 8 })

        Text('您的贴心智能礼物宝库')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()

      // 版权信息
      Text('© 2025 送什么礼团队')
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
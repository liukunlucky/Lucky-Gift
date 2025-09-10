import router from '@ohos.router';
import { Contact, Inspiration, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { InspirationDAO } from '../../database/InspirationDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';

// 菜单项接口定义
interface MenuItem {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  count?: number;
}

interface DataMenuItem {
  id: string;
  title: string;
  description: string;
  icon: string;
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
  @State isLoading: boolean = true;
  @State showExportDialog: boolean = false;
  @State showImportDialog: boolean = false;
  @State exportProgress: number = 0;
  @State importProgress: number = 0;
  
  private dbManager = new NewDatabaseManager();
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(this.dbManager);
  
  // 功能菜单配置
  private menuItems: MenuItem[] = [
    {
      id: 'relationships',
      title: '我的关系网络',
      description: '管理联系人和重要关系',
      icon: '👥',
      color: '#4CAF50',
      count: 0
    },
    {
      id: 'favorites',
      title: '我的收藏',
      description: '收藏的灵感和创意',
      icon: '❤️',
      color: '#E91E63',
      count: 0
    },
    {
      id: 'reminders',
      title: '礼物提醒',
      description: '重要日期提醒设置',
      icon: '🔔',
      color: '#FF9800',
      count: 0
    },
    {
      id: 'statistics',
      title: '送礼统计',
      description: '查看送礼数据分析',
      icon: '📊',
      color: '#2196F3',
      count: 0
    }
  ];
  
  // 数据管理菜单
  private dataMenuItems: DataMenuItem[] = [
    {
      id: 'export',
      title: '导出数据',
      description: '备份所有送礼记录',
      icon: '📤',
      color: '#9C27B0'
    },
    {
      id: 'import',
      title: '导入数据',
      description: '恢复之前的备份',
      icon: '📥',
      color: '#607D8B'
    },
    {
      id: 'clear',
      title: '清空数据',
      description: '删除所有本地数据',
      icon: '🗑️',
      color: '#F44336'
    }
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载联系人
      this.contacts = await this.contactDAO.getAllContacts();
      
      // 加载收藏的灵感
      this.favoriteInspirations = await this.inspirationDAO.getFavoriteInspirations();
      
      // 加载统计数据
      const stats = await this.giftEventDAO.getGiftEventStats();
      this.totalGiftEvents = stats.totalEvents;
      this.totalSpent = stats.totalSpent;
      
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
          // 计算有提醒设置的联系人数量
          item.count = this.contacts.filter(c => c.importantDates && c.importantDates.length > 0).length;
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
          url: 'pages/ContactListPage'
        });
        break;
      case 'favorites':
        router.pushUrl({
          url: 'pages/FavoriteInspirationPage'
        });
        break;
      case 'reminders':
        router.pushUrl({
          url: 'pages/ReminderSettingsPage'
        });
        break;
      case 'statistics':
        router.pushUrl({
          url: 'pages/StatisticsPage'
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

  // 导出数据
  async exportData() {
    try {
      this.exportProgress = 0;
      
      // 收集所有数据
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
      // 顶部个人信息卡片
      Column() {
        Row() {
          // 头像
          Image($r('app.media.ic_mine'))
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor('#F0F0F0')
          
          Column() {
            Text('我的送礼智库')
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
        }
        .width('100%')
        .margin({ bottom: 20 })
        
        // 统计数据
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
            
            Text('送礼记录')
              .fontSize(12)
              .fontColor('#FFE0D6')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          
          Column() {
            Text(`¥${this.formatAmount(this.totalSpent)}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            
            Text('总花费')
              .fontSize(12)
              .fontColor('#FFE0D6')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          
          Column() {
            Text(this.favoriteInspirations.length.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            
            Text('收藏灵感')
              .fontSize(12)
              .fontColor('#FFE0D6')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FF6B35')
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })

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
        .height('60%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 功能菜单
            Column() {
              Text('我的功能')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })
                .alignSelf(ItemAlign.Start)
              
              ForEach(this.menuItems, (item: MenuItem) => {
                Row() {
                  Row() {
                    Text(item.icon)
                      .fontSize(24)
                      .margin({ right: 12 })
                    
                    Column() {
                      Text(item.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      
                      Text(item.description)
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .layoutWeight(1)
                  
                  Row() {
                    if (item.count !== undefined && item.count > 0) {
                      Text(item.count.toString())
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ right: 8 })
                    }
                    
                    Image($r('app.media.ic_arrow_right'))
                      .width(16)
                      .height(16)
                      .fillColor('#CCCCCC')
                  }
                }
                .width('100%')
                .height(60)
                .padding({ left: 16, right: 16 })
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.navigateToFeature(item.id);
                })
              })
            }
            .width('100%')
            .padding(16)
            .margin({ top: 8 })

            // 数据管理
            Column() {
              Text('数据管理')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })
                .alignSelf(ItemAlign.Start)
              
              ForEach(this.dataMenuItems, (item: DataMenuItem) => {
                Row() {
                  Row() {
                    Text(item.icon)
                      .fontSize(24)
                      .margin({ right: 12 })
                    
                    Column() {
                      Text(item.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      
                      Text(item.description)
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .layoutWeight(1)
                  
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .fillColor('#CCCCCC')
                }
                .width('100%')
                .height(60)
                .padding({ left: 16, right: 16 })
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.handleDataOperation(item.id);
                })
              })
            }
            .width('100%')
            .padding(16)

            // 最近联系人
            if (this.contacts.length > 0) {
              Column() {
                Row() {
                  Text('最近联系人')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  
                  Blank()
                  
                  Text('查看全部')
                    .fontSize(12)
                    .fontColor('#FF6B35')
                    .onClick(() => {
                      this.navigateToFeature('relationships');
                    })
                }
                .width('100%')
                .margin({ bottom: 16 })
                
                Row() {
                  ForEach(this.contacts.slice(0, 4), (contact: Contact) => {
                    Column() {
                      Text(contact.avatar || '👤')
                        .fontSize(30)
                        .width(50)
                        .height(50)
                        .borderRadius(25)
                        .backgroundColor('#F0F0F0')
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#F0F0F0')
                      
                      Text(contact.name)
                        .fontSize(12)
                        .fontColor('#333333')
                        .margin({ top: 6 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width(60)
                    .margin({ right: 12 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/profile/ContactDetailPage',
                        params: { contactId: contact.id }
                      });
                    })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 20 })
            }
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showExportDialog, this.buildExportDialog(), {
      height: 300,
      dragBar: true
    })
    .bindSheet($$this.showImportDialog, this.buildImportDialog(), {
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
            
            Text(`• ${this.totalGiftEvents} 条送礼记录`)
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
}
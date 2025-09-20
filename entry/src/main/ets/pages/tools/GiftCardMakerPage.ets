import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import image from '@ohos.multimedia.image';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import promptAction from '@ohos.promptAction';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { Context } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';

interface CardTemplate {
  id: string;
  name: string;
  preview: string;
  backgroundColor: string;
  textColor: string;
  accentColor: string;
  style: 'classic' | 'modern' | 'cute' | 'elegant';
}

interface CardData {
  template: CardTemplate;
  customMessage: string;
  senderName: string;
  receiverName: string;
}

@Entry
@Component
struct GiftCardMakerPage {
  @State selectedTemplate: CardTemplate | null = null;
  @State customMessage: string = '';
  @State senderName: string = '';
  @State receiverName: string = '';
  @State isSaving: boolean = false;
  
  // 预置模板
  private templates: CardTemplate[] = [
    {
      id: 'classic_1',
      name: '经典祝福',
      preview: '/common/images/card_classic_1.png',
      backgroundColor: '#FFFFFF',
      textColor: '#333333',
      accentColor: '#FF6B35',
      style: 'classic'
    },
    {
      id: 'modern_1',
      name: '现代简约',
      preview: '/common/images/card_modern_1.png',
      backgroundColor: '#F8F9FA',
      textColor: '#2C3E50',
      accentColor: '#3498DB',
      style: 'modern'
    },
    {
      id: 'cute_1',
      name: '可爱风格',
      preview: '/common/images/card_cute_1.png',
      backgroundColor: '#FFE5E5',
      textColor: '#E91E63',
      accentColor: '#FF69B4',
      style: 'cute'
    },
    {
      id: 'elegant_1',
      name: '优雅金色',
      preview: '/common/images/card_elegant_1.png',
      backgroundColor: '#1A1A1A',
      textColor: '#FFFFFF',
      accentColor: '#FFD700',
      style: 'elegant'
    },
    {
      id: 'classic_2',
      name: '温馨粉色',
      preview: '/common/images/card_classic_2.png',
      backgroundColor: '#FFF0F5',
      textColor: '#8B4B8B',
      accentColor: '#DDA0DD',
      style: 'classic'
    },
    {
      id: 'modern_2',
      name: '清新绿色',
      preview: '/common/images/card_modern_2.png',
      backgroundColor: '#F0FFF0',
      textColor: '#2E8B57',
      accentColor: '#32CD32',
      style: 'modern'
    },
    {
      id: 'cute_2',
      name: '梦幻紫色',
      preview: '/common/images/card_cute_2.png',
      backgroundColor: '#F5F0FF',
      textColor: '#6A5ACD',
      accentColor: '#9370DB',
      style: 'cute'
    },
    {
      id: 'elegant_2',
      name: '深蓝商务',
      preview: '/common/images/card_elegant_2.png',
      backgroundColor: '#191970',
      textColor: '#FFFFFF',
      accentColor: '#87CEEB',
      style: 'elegant'
    }
  ];
  
  aboutToAppear() {
    // 设置默认模板
    this.selectedTemplate = this.templates[0];
  }
  
  selectTemplate(template: CardTemplate) {
    this.selectedTemplate = template;
  }
  
  // 验证表单是否完整
  private isFormValid(): boolean {
    return this.selectedTemplate !== null && 
           this.receiverName.trim().length > 0 && 
           this.customMessage.trim().length > 0;
  }
  
  // 获取缺失的字段信息
  private getMissingFields(): string[] {
    const missing: string[] = [];
    if (!this.selectedTemplate) {
      missing.push('模板');
    }
    if (!this.receiverName.trim()) {
      missing.push('收件人');
    }
    if (!this.customMessage.trim()) {
      missing.push('祝福语');
    }
    return missing;
  }
  
  // 显示缺失字段的提示
  private showMissingFieldsToast() {
    const missingFields = this.getMissingFields();
    if (missingFields.length > 0) {
      const message = `请填写：${missingFields.join('、')}`;
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    }
  }
  
  togglePreview() {
    if (!this.isFormValid()) {
      this.showMissingFieldsToast();
      return;
    }
    
    // 跳转到预览页面
    const cardData: CardData = {
      template: this.selectedTemplate!,
      customMessage: this.customMessage,
      senderName: this.senderName,
      receiverName: this.receiverName
    };
    
    router.pushUrl({
      url: 'pages/tools/GiftCardPreviewPage',
      params: {
        cardData: cardData
      }
    }).catch((error: Error) => {
      console.error('跳转预览页面失败:', error);
      promptAction.showToast({
        message: '跳转失败，请重试',
        duration: 2000
      });
    });
  }
  
  async saveCard() {
    if (!this.selectedTemplate || !this.customMessage.trim()) {
      return;
    }
    
    try {
      this.isSaving = true;
      
      await this.generateAndSaveCard();
      
      // 显示成功提示
      this.showSuccessMessage();
      
    } catch (error) {
      console.error('保存卡片失败:', error);
      this.showErrorMessage(error as Error);
    } finally {
      this.isSaving = false;
    }
  }
  
  async generateAndSaveCard() {
    try {
      // 1. 使用componentSnapshot截取卡片预览
      const pixelMap = await componentSnapshot.get('giftCardPreview');
      
      if (!pixelMap) {
        throw new Error('截图失败');
      }
      
      // 2. 获取应用上下文
      const context = getContext(this) as common.UIAbilityContext;
      
      // 3. 创建PhotoAccessHelper实例
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 4. 将PixelMap转换为ArrayBuffer
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90
      };
      
      const arrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      
      // 5. 生成文件名
      const timestamp = new Date().getTime();
      const fileName = `gift_card_${timestamp}.jpg`;
      
      // 6. 创建相册资源
      const uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      
      // 7. 打开文件并写入图片数据
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, arrayBuffer);
      await fs.close(file.fd);
      
      console.log('礼物卡已成功保存到相册');
      
    } catch (error) {
      console.error('生成卡片失败:', error);
      const businessError = error as BusinessError;
      if (businessError.code === 201) {
        throw new Error('需要相册访问权限才能保存图片');
      } else if (businessError.code === 14000011) {
        throw new Error('截图失败，请重试');
      } else {
        throw new Error('保存到相册失败，请检查存储空间');
      }
    }
  }


  
  showSuccessMessage() {
    // 显示保存成功的提示
    console.log('卡片已保存到相册');
  }

  showErrorMessage(error: Error) {
    // 显示错误提示
    let message = '保存失败';
    if (error.message.includes('权限')) {
      message = '需要相册访问权限才能保存图片';
    } else if (error.message.includes('截图')) {
      message = '截图失败，请重试';
    } else if (error.message.includes('保存')) {
      message = '保存到相册失败，请检查存储空间';
    }
    console.error('保存礼物卡失败:', message);
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.goBack()
        })
        
        Text('礼物卡制作器')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button() {
          Text('预览')
            .fontSize(16)
            .fontColor(this.isFormValid() ? '#FF6B35' : '#CCCCCC')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .opacity(this.isFormValid() ? 1.0 : 0.6)
        .onClick(() => this.togglePreview())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 编辑模式
        Scroll() {
          Column() {
            // 模板选择
            Column() {
              Text('选择模板')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 16 })
              
              Grid() {
                ForEach(this.templates, (template: CardTemplate) => {
                  GridItem() {
                    Column() {
                      // 模板预览
                      Column() {
                        Text('礼物卡')
                          .fontSize(12)
                          .fontColor(template.textColor)
                          .fontWeight(FontWeight.Bold)
                        
                        Text('❤️')
                          .fontSize(16)
                          .margin({ top: 4 })
                        
                        Text('祝福语')
                          .fontSize(10)
                          .fontColor(template.accentColor)
                          .margin({ top: 4 })
                      }
                      .width('100%')
                      .height(80)
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor(template.backgroundColor)
                      .borderRadius(8)
                      .border({
                        width: this.selectedTemplate?.id === template.id ? 2 : 1,
                        color: this.selectedTemplate?.id === template.id ? '#FF6B35' : '#E0E0E0'
                      })
                      
                      Text(template.name)
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 8 })
                        .textAlign(TextAlign.Center)
                    }
                    .onClick(() => this.selectTemplate(template))
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(12)
              .rowsGap(16)
              .width('100%')
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 文字编辑
            Column() {
              Text('编辑内容')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 16 })
              
              // 收件人
              Column() {
                Text('收件人')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: '输入收件人姓名', text: this.receiverName })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.receiverName = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 祝福语
              Column() {
                Text('祝福语')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextArea({ placeholder: '写下你的祝福语...', text: this.customMessage })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding(16)
                  .height(120)
                  .onChange((value: string) => {
                    this.customMessage = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 发件人
              Column() {
                Text('发件人')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: '输入你的姓名' })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.senderName = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 快速模板文字
            Column() {
              Text('快速模板')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 16 })
              
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.getQuickTemplates(), (template: string) => {
                  Button(template)
                    .fontSize(12)
                    .fontColor('#666666')
                    .backgroundColor('#F5F5F5')
                    .borderRadius(16)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.customMessage = template;
                    })
                })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
  
  @Builder
  CardPreview() {
    if (this.selectedTemplate) {
      Stack() {
        // 卡片背景
        Rect()
          .width(300)
          .height(200)
          .fill(this.selectedTemplate.backgroundColor)
          .borderRadius(16)
          .shadow({
            radius: 20,
            color: '#00000020',
            offsetX: 0,
            offsetY: 8
          })
        
        // 卡片内容
        Column() {
          // 装饰元素
          Text('🎁')
            .fontSize(24)
            .margin({ bottom: 8 })
          
          // 收件人
          if (this.receiverName) {
            Text(`亲爱的 ${this.receiverName}`)
              .fontSize(14)
              .fontColor(this.selectedTemplate!.textColor)
              .margin({ bottom: 12 })
          }
          
          // 祝福语
          Text(this.customMessage || '在这里写下你的祝福语...')
            .fontSize(16)
            .fontColor(this.selectedTemplate!.textColor)
            .textAlign(TextAlign.Center)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(24)
            .margin({ bottom: 16 })
          
          // 发件人
          if (this.senderName) {
            Text(`—— ${this.senderName}`)
              .fontSize(12)
              .fontColor(this.selectedTemplate!.accentColor)
              .alignSelf(ItemAlign.End)
          }
        }
        .width(260)
        .padding(20)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
  }
  
  getQuickTemplates(): string[] {
    return [
      '生日快乐！愿你的每一天都充满阳光和快乐！',
      '感谢你一直以来的陪伴，这份小礼物代表我的心意。',
      '愿这份礼物能带给你温暖和惊喜！',
      '虽然礼物不贵重，但承载着我满满的祝福。',
      '希望你会喜欢这份精心挑选的礼物！',
      '愿我们的友谊如这份礼物一样珍贵！',
      '新年快乐！愿新的一年里一切顺利！',
      '恭喜你！这份礼物是对你成就的小小庆祝。',
      '谢谢你的帮助，这是我的一点心意。',
      '愿这份礼物能让你感受到我的关爱。'
    ];
  }
}
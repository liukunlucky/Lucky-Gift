import router from '@ohos.router';
import { GiftStory, GiftEvent } from '../model/NewDataModels';
import { GiftStoryDAO } from '../dao/GiftStoryDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import picker from '@ohos.file.picker';
import { GiftEventDAO } from '../database/GiftEventDAO';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CreateGiftStoryPage {
  @State title: string = '';
  @State content: string = '';
  @State emotion: string = '';
  @State reason: string = '';
  @State scene: string = '';
  @State selectedImages: string[] = [];
  @State tags: string[] = [];
  @State newTag: string = '';
  @State selectedGiftEvent: GiftEvent | null = null;
  @State giftEvents: GiftEvent[] = [];
 @State private showGiftEventSelector: boolean = false;
  @State private isLoading: boolean = false;
  @State isEditMode: boolean = false;
  @State editingStoryId: string = '';

  private dbManager = new NewDatabaseManager();
  private giftStoryDAO: GiftStoryDAO | null = null;
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(this.dbManager);

  aboutToAppear() {
    this.initDatabase();
    this.loadParams();
    this.loadGiveEventData();
  }

  private loadParams() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.story) {
      const story = params.story as GiftStory;
      this.isEditMode = true;
      this.editingStoryId = story.id || '';
      this.title = story.title;
      this.content = story.content;
      this.emotion = story.emotion || '';
      this.reason = story.reason || '';
      this.scene = story.scene || '';
      this.selectedImages = story.images || [];
      this.tags = story.tags || [];
    }
  }

  async loadGiveEventData() {
    try {
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      console.log('记录页面：加载到的事件数量:', this.giftEvents.length);
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
    }
  }

  private async initDatabase() {
    try {
      if (!this.dbManager.isInitialized()) {
        await this.dbManager.initDatabase(getContext(this));
      }
      const rdbStore = this.dbManager.getRdbStore();
      if (rdbStore) {
        this.giftStoryDAO = new GiftStoryDAO(rdbStore);
        await this.loadGiftEvents();
      }
    } catch (error) {
      console.error('初始化数据库失败:', error);
    }
  }

  private async loadGiftEvents() {
    if (!this.giftEventDAO) {
      console.error('giftEventDAO 未初始化');
      return;
    }

    try {
      console.info('开始加载礼物记录...');
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      console.info(`成功加载礼物记录数量: ${this.giftEvents.length}`);
      if (this.giftEvents.length > 0) {
        const eventSummaries: Record<string, string>[] = [];
        this.giftEvents.forEach(event => {
          const summary: Record<string, string> = {};
          summary.id = event.id || '';
          summary.giftIdea = event.giftIdea;
          summary.contactName = event.contactName;
          eventSummaries.push(summary);
        });
        console.info('礼物记录详情:', JSON.stringify(eventSummaries));
      }
    } catch (error) {
      console.error('加载礼物记录失败:', error);
      this.giftEvents = []; // 确保在出错时设置为空数组
    }
  }

  private async onSelectImages() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 3 - this.selectedImages.length;

      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
      
      if (photoSelectResult && photoSelectResult.photoUris) {
        this.selectedImages = this.selectedImages.concat(photoSelectResult.photoUris);
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }

  private onRemoveImage(index: number) {
    this.selectedImages.splice(index, 1);
  }

  private onAddTag() {
    if (this.newTag.trim() && !this.tags.includes(this.newTag.trim())) {
      this.tags.push(this.newTag.trim());
      this.newTag = '';
    }
  }

  private onRemoveTag(index: number) {
    this.tags.splice(index, 1);
  }

  private onSelectGiftEvent(event: GiftEvent) {
    this.selectedGiftEvent = event;
    this.showGiftEventSelector = false;
  }

  private async onSave() {
    if (!this.validateForm()) return;
    if (!this.giftStoryDAO || !this.selectedGiftEvent) return;

    this.isLoading = true;

    try {
      const storyData: GiftStory = {
        giftEventId: this.selectedGiftEvent.id || '',
        giftEventTitle: this.selectedGiftEvent.giftIdea,
        contactName: this.selectedGiftEvent.contactName,
        title: this.title,
        content: this.content,
        images: this.selectedImages,
        emotion: this.emotion,
        reason: this.reason,
        scene: this.scene,
        tags: this.tags
      };

      if (this.isEditMode) {
        await this.giftStoryDAO.updateGiftStory(this.editingStoryId, storyData);
      } else {
        await this.giftStoryDAO.createGiftStory(storyData);
      }

      router.back();
      AppStorage.setOrCreate('refreshStoryPage', Date.now());
    } catch (error) {
      console.error('保存故事失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private validateForm(): boolean {
    if (!this.title.trim()) {
      return false;
    }
    if (!this.content.trim()) {
      return false;
    }
    if (!this.selectedGiftEvent) {
      return false;
    }
    return true;
  }

  private onBack() {
    router.back();
  }

  private showDeleteConfirmDialog() {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这个故事吗？\n删除后无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除');
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4444',
        action: () => {
          this.onDeleteStory();
        }
      }
    });
  }

  private async onDeleteStory() {
    try {
      this.isLoading = true;

      if (this.isEditMode && this.editingStoryId && this.giftStoryDAO) {
        await this.giftStoryDAO.deleteGiftStory(this.editingStoryId);
        router.back();
        AppStorage.setOrCreate('refreshStoryPage', Date.now());
      }
    } catch (error) {
      console.error('删除故事失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      // 主页面内容
      Column() {
        // 顶部导航栏
        this.buildNavigationBar()

        // 内容区域
        Scroll() {
          Column({ space: 20 }) {
            // 选择礼物记录
            this.buildGiftEventSelector()

            // 故事标题
            this.buildTitleInput()

            // 故事内容
            this.buildContentInput()

            // 图片上传
            this.buildImageUpload()

            // 情感描述
            this.buildEmotionInput()

            // 选择原因
            this.buildReasonInput()

            // 情景描述
            this.buildSceneInput()

            // 标签
            this.buildTagsInput()

            // 底部按钮区域
            this.buildBottomButtons()
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 礼物选择器弹窗
      if (this.showGiftEventSelector) {
        this.buildGiftEventSelectorDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildNavigationBar() {
    Row() {
      Button('取消')
        .backgroundColor(Color.Transparent)
        .fontColor('#007AFF')
        .onClick(() => {
          this.onBack();
        })

      Text(this.isEditMode ? '编辑故事' : '创建故事')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('保存')
        .backgroundColor(Color.Transparent)
        .fontColor(this.validateForm() ? '#007AFF' : '#CCCCCC')
        .enabled(this.validateForm())
        .onClick(() => {
          this.onSave();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  buildGiftEventSelector() {
    Column({ space: 8 }) {
      Row() {
        Text('选择礼物记录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('*')
          .fontSize(16)
          .fontColor('#FF4444')
      }

      if (this.selectedGiftEvent) {
        Row() {
          Column({ space: 4 }) {
            Text(this.selectedGiftEvent.giftIdea)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            Text(`送给 ${this.selectedGiftEvent.contactName}`)
              .fontSize(12)
              .fontColor('#666666')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('更换')
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .borderRadius(12)
            .onClick(() => {
              this.showGiftEventSelector = true;
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
      } else {
        Button(this.giftEvents.length > 0 ? '选择礼物记录' : '暂无礼物记录，请先创建')
          .width('100%')
          .backgroundColor('#F8F8F8')
          .fontColor('#666666')
          .borderRadius(8)
          .enabled(this.giftEvents.length > 0)
          .onClick(() => {
            if (this.giftEvents.length > 0) {
              this.showGiftEventSelector = true;
            } else {
              promptAction.showToast({
                message: '您还没创建送礼记录',
                duration: 2000
              });
            }

          })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTitleInput() {
    Column({ space: 8 }) {
      Row() {
        Text('故事标题')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('*')
          .fontSize(16)
          .fontColor('#FF4444')
      }

      TextInput({ placeholder: '给这个故事起个标题...' })
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.title = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildContentInput() {
    Column({ space: 8 }) {
      Row() {
        Text('故事内容')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('*')
          .fontSize(16)
          .fontColor('#FF4444')
      }

      TextArea({ placeholder: '讲述这份礼物背后的故事...' })
        .width('100%')
        .height(120)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.content = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildImageUpload() {
    Column({ space: 8 }) {
      Text('照片（最多3张）')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      if (this.selectedImages.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.selectedImages, (imagePath: string, index: number) => {
            Stack() {
              Image(imagePath)
                .width(80)
                .height(80)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)

              Button('×')
                .width(24)
                .height(24)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4444')
                .borderRadius(12)
                .position({ x: 60, y: -4 })
                .onClick(() => {
                  this.onRemoveImage(index);
                })
            }
          }, (imagePath: string, index: number) => `image_${index}`)

          if (this.selectedImages.length < 3) {
            Button('+')
              .width(80)
              .height(80)
              .fontSize(24)
              .fontColor('#CCCCCC')
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5', style: BorderStyle.Dashed })
              .onClick(() => {
                this.onSelectImages();
              })
          }
        }
      } else {
        Button('+ 添加照片')
          .width('100%')
          .height(80)
          .fontSize(16)
          .fontColor('#CCCCCC')
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .border({ width: 1, color: '#E5E5E5', style: BorderStyle.Dashed })
          .onClick(() => {
            this.onSelectImages();
          })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildEmotionInput() {
    Column({ space: 8 }) {
      Text('当时的心情')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '描述当时的心情和感受...' })
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.emotion = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildReasonInput() {
    Column({ space: 8 }) {
      Text('选择原因')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '为什么选择这个礼物...' })
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.reason = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSceneInput() {
    Column({ space: 8 }) {
      Text('情景描述')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '描述当时的情景和环境...' })
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.scene = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTagsInput() {
    Column({ space: 8 }) {
      Text('标签')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)

      Row({ space: 8 }) {
        TextInput({ placeholder: '添加标签...' })
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(12)
          .onChange((value: string) => {
            this.newTag = value;
          })

        Button('添加')
          .padding({ left: 16, right: 16 })
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.onAddTag();
          })
      }

      if (this.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (tag: string, index: number) => {
            Row({ space: 4 }) {
              Text(tag)
                .fontSize(12)
                .fontColor('#007AFF')

              Button('×')
                .width(16)
                .height(16)
                .fontSize(10)
                .fontColor('#666666')
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.onRemoveTag(index);
                })
            }
            .padding({ left: 8, right: 4, top: 4, bottom: 4 })
            .backgroundColor('#E6F3FF')
            .borderRadius(12)
          }, (tag: string, index: number) => `tag_${index}`)
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildBottomButtons() {
    Column({ space: 12 }) {
      // 保存按钮
      Button(this.isLoading ? '保存中...' : '保存故事')
        .width('100%')
        .height(48)
        .backgroundColor(this.validateForm() ? '#007AFF' : '#CCCCCC')
        .fontColor('#FFFFFF')
        .borderRadius(24)
        .enabled(!this.isLoading && this.validateForm())
        .onClick(() => {
          this.onSave();
        })

      // 删除按钮（仅在编辑模式下显示）
      if (this.isEditMode) {
        Button('删除故事')
          .width('100%')
          .height(48)
          .backgroundColor('#FF4444')
          .fontColor('#FFFFFF')
          .borderRadius(24)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.showDeleteConfirmDialog();
          })
      }
    }
    .width('100%')
  }

  @Builder
  buildSaveButton() {
    Button(this.isLoading ? '保存中...' : '保存故事')
      .width('100%')
      .height(48)
      .backgroundColor(this.validateForm() ? '#007AFF' : '#CCCCCC')
      .fontColor('#FFFFFF')
      .borderRadius(24)
      .enabled(!this.isLoading && this.validateForm())
      .onClick(() => {
        this.onSave();
      })
  }



  @Builder
  buildGiftEventSelectorDialog() {
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showGiftEventSelector = false;
        })

      // 弹窗内容
      Column() {
        // 标题栏
        Row() {
          Text('选择礼物记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)

          Button('取消')
            .backgroundColor(Color.Transparent)
            .fontColor('#007AFF')
            .onClick(() => {
              this.showGiftEventSelector = false;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        Divider()
          .color('#E5E5E5')

        // 礼物列表
        if (this.giftEvents.length > 0) {
          List() {
            ForEach(this.giftEvents, (giftEvent: GiftEvent) => {
              ListItem() {
                Row() {
                  Column({ space: 4 }) {
                    Text(giftEvent.giftIdea)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(`送给 ${giftEvent.contactName}`)
                      .fontSize(14)
                      .fontColor('#666666')

                    if (giftEvent.date) {
                      Text(giftEvent.date)
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  if (this.selectedGiftEvent && this.selectedGiftEvent.id === giftEvent.id) {
                    Text('✓')
                      .fontSize(20)
                      .fontColor('#007AFF')
                  }
                }
                .width('100%')
                .padding(16)
                .onClick(() => {
                  this.selectedGiftEvent = giftEvent;
                  this.showGiftEventSelector = false;
                })
              }
            }, (giftEvent: GiftEvent) => giftEvent.id?.toString() || '')
          }
          .layoutWeight(1)
          .divider({ strokeWidth: 0.5, color: '#E5E5E5' })
        } else {
          Column() {
            Text('暂无礼物记录')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 40, bottom: 20 })

            Text('请先创建送礼记录')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('90%')
      .height('70%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}
import { Gift, Scenario, GiftCategory, PriceRange, Gender, AgeRange, Relationship, Interest, GiftRecommendationRequest } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';
import router from '@ohos.router';

// 人群分析接口
interface TargetProfile {
  gender?: Gender;
  ageRange?: AgeRange;
  relationship?: Relationship;
  interests: string[];
  budget?: number;
}

// 兴趣标签接口
interface InterestTag {
  id: string;
  name: string;
  icon: string;
  color: string;
}

@Entry
@Component
struct TargetAnalysisPage {
  @State private targetProfile: TargetProfile = {
    interests: []
  };
  @State private recommendedGifts: Gift[] = [];
  @State private currentStep: number = 1;
  @State private loading: boolean = false;
  @State private showResults: boolean = false;
  
  private giftService = GiftRecommendationService.getInstance();
  
  // 兴趣标签数据
  private interestTags: InterestTag[] = [
    { id: 'sports', name: '运动健身', icon: '🏃', color: '#FF6B6B' },
    { id: 'reading', name: '阅读学习', icon: '📚', color: '#4ECDC4' },
    { id: 'music', name: '音乐艺术', icon: '🎵', color: '#45B7D1' },
    { id: 'cooking', name: '烹饪美食', icon: '👨‍🍳', color: '#FFA07A' },
    { id: 'travel', name: '旅行探索', icon: '✈️', color: '#98D8C8' },
    { id: 'gaming', name: '游戏娱乐', icon: '🎮', color: '#F7DC6F' },
    { id: 'fashion', name: '时尚美妆', icon: '💄', color: '#BB8FCE' },
    { id: 'tech', name: '科技数码', icon: '📱', color: '#85C1E9' },
    { id: 'pets', name: '宠物养护', icon: '🐕', color: '#F8C471' },
    { id: 'gardening', name: '园艺植物', icon: '🌱', color: '#82E0AA' },
    { id: 'photography', name: '摄影拍照', icon: '📷', color: '#D7BDE2' },
    { id: 'handcraft', name: '手工制作', icon: '🎨', color: '#F9E79F' }
  ];

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      if (this.showResults) {
        // 推荐结果页
        this.buildResultsPage()
      } else {
        // 分析步骤页
        this.buildAnalysisSteps()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Button('← 返回')
        .fontSize(16)
        .backgroundColor(Color.Transparent)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text(this.showResults ? '推荐结果' : '人群分析')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      if (!this.showResults) {
        Text(`${this.currentStep}/4`)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#E0E0E0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildAnalysisSteps() {
    Column() {
      // 进度条
      this.buildProgressBar()
      
      // 步骤内容
      if (this.currentStep === 1) {
        this.buildGenderStep()
      } else if (this.currentStep === 2) {
        this.buildAgeStep()
      } else if (this.currentStep === 3) {
        this.buildRelationshipStep()
      } else if (this.currentStep === 4) {
        this.buildInterestsStep()
      }
      
      // 底部按钮
      this.buildBottomButtons()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildProgressBar() {
    Column() {
      Row() {
        ForEach([1, 2, 3, 4], (step: number) => {
          Circle({ width: 24, height: 24 })
            .fill(step <= this.currentStep ? '#4CAF50' : '#E0E0E0')
            .margin({ right: step < 4 ? 8 : 0 })
          
          if (step < 4) {
            Line()
              .width(40)
              .height(2)
              .backgroundColor(step < this.currentStep ? '#4CAF50' : '#E0E0E0')
              .margin({ right: 8 })
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      
      Row() {
        Text('性别')
          .fontSize(12)
          .fontColor(this.currentStep >= 1 ? '#4CAF50' : '#999999')
          .width(60)
          .textAlign(TextAlign.Center)
        
        Text('年龄')
          .fontSize(12)
          .fontColor(this.currentStep >= 2 ? '#4CAF50' : '#999999')
          .width(60)
          .textAlign(TextAlign.Center)
        
        Text('关系')
          .fontSize(12)
          .fontColor(this.currentStep >= 3 ? '#4CAF50' : '#999999')
          .width(60)
          .textAlign(TextAlign.Center)
        
        Text('兴趣')
          .fontSize(12)
          .fontColor(this.currentStep >= 4 ? '#4CAF50' : '#999999')
          .width(60)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .margin({ bottom: 16 })
  }

  @Builder
  buildGenderStep() {
    Column() {
      Text('请选择TA的性别')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      Text('这将帮助我们推荐更合适的礼物')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 32 })
      
      Row() {
        this.buildGenderOption('👨', '男性', Gender.MALE)
        this.buildGenderOption('👩', '女性', Gender.FEMALE)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGenderOption(icon: string, label: string, gender: Gender) {
    Column() {
      Text(icon)
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text(label)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.targetProfile.gender === gender ? Color.White : '#333333')
    }
    .width(120)
    .height(140)
    .backgroundColor(this.targetProfile.gender === gender ? '#4CAF50' : '#F5F5F5')
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.targetProfile.gender = gender;
    })
  }

  @Builder
  buildAgeStep() {
    Column() {
      Text('请选择TA的年龄段')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      Text('不同年龄段的人有不同的喜好')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 32 })
      
      Grid() {
        GridItem() {
          this.buildAgeOption('👶', '儿童\n(0-12岁)', AgeRange.CHILD)
        }
        GridItem() {
          this.buildAgeOption('🧒', '青少年\n(13-17岁)', AgeRange.TEEN)
        }
        GridItem() {
          this.buildAgeOption('👨', '青年\n(18-30岁)', AgeRange.YOUNG_ADULT)
        }
        GridItem() {
          this.buildAgeOption('👨‍💼', '成年\n(31-50岁)', AgeRange.ADULT)
        }
        GridItem() {
          this.buildAgeOption('👴', '老年\n(50岁以上)', AgeRange.SENIOR)
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(16)
      .columnsGap(16)
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildAgeOption(icon: string, label: string, ageRange: AgeRange) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 12 })
      
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.targetProfile.ageRange === ageRange ? Color.White : '#333333')
        .textAlign(TextAlign.Center)
        .lineHeight(18)
    }
    .width('100%')
    .height(100)
    .backgroundColor(this.targetProfile.ageRange === ageRange ? '#4CAF50' : '#F5F5F5')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.targetProfile.ageRange = ageRange;
    })
  }

  @Builder
  buildRelationshipStep() {
    Column() {
      Text('你们的关系是？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      Text('关系不同，礼物的选择也会不同')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 32 })
      
      Grid() {
        GridItem() {
          this.buildRelationshipOption('💕', '恋人', Relationship.ROMANTIC)
        }
        GridItem() {
          this.buildRelationshipOption('👨‍👩‍👧‍👦', '家人', Relationship.FAMILY)
        }
        GridItem() {
          this.buildRelationshipOption('👫', '朋友', Relationship.FRIEND)
        }
        GridItem() {
          this.buildRelationshipOption('👔', '同事', Relationship.COLLEAGUE)
        }
        GridItem() {
          this.buildRelationshipOption('👨‍🏫', '老师', Relationship.TEACHER)
        }
        GridItem() {
          this.buildRelationshipOption('🤝', '熟人', Relationship.ACQUAINTANCE)
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(16)
      .columnsGap(16)
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildRelationshipOption(icon: string, label: string, relationship: Relationship) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 12 })
      
      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.targetProfile.relationship === relationship ? Color.White : '#333333')
    }
    .width('100%')
    .height(80)
    .backgroundColor(this.targetProfile.relationship === relationship ? '#4CAF50' : '#F5F5F5')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.targetProfile.relationship = relationship;
    })
  }

  @Builder
  buildInterestsStep() {
    Column() {
      Text('TA的兴趣爱好是？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      Text('可以选择多个，这样推荐会更精准')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 24 })
      
      Grid() {
        ForEach(this.interestTags, (tag: InterestTag) => {
          GridItem() {
            this.buildInterestTag(tag)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildInterestTag(tag: InterestTag) {
    Column() {
      Text(tag.icon)
        .fontSize(24)
        .margin({ bottom: 8 })
      
      Text(tag.name)
        .fontSize(12)
        .fontColor(this.targetProfile.interests.includes(tag.id) ? Color.White : '#333333')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(70)
    .backgroundColor(this.targetProfile.interests.includes(tag.id) ? tag.color : '#F5F5F5')
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.targetProfile.interests.includes(tag.id)) {
        const index = this.targetProfile.interests.indexOf(tag.id);
        if (index > -1) {
          this.targetProfile.interests.splice(index, 1);
        }
      } else {
        this.targetProfile.interests.push(tag.id);
      }
    })
  }

  @Builder
  buildBottomButtons() {
    Row() {
      if (this.currentStep > 1) {
        Button('上一步')
          .fontSize(16)
          .backgroundColor('#E0E0E0')
          .fontColor('#333333')
          .borderRadius(25)
          .width(100)
          .height(50)
          .onClick(() => {
            this.currentStep--;
          })
      }
      
      Blank()
      
      Button(this.currentStep === 4 ? '开始分析' : '下一步')
        .fontSize(16)
        .backgroundColor(this.canProceed() ? '#4CAF50' : '#CCCCCC')
        .fontColor(Color.White)
        .borderRadius(25)
        .width(this.currentStep === 4 ? 120 : 100)
        .height(50)
        .enabled(this.canProceed())
        .onClick(() => {
          if (this.currentStep === 4) {
            this.startAnalysis();
          } else {
            this.currentStep++;
          }
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildResultsPage() {
    Column() {
      // 分析结果摘要
      this.buildAnalysisSummary()
      
      // 推荐礼物列表
      this.buildRecommendedGifts()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildAnalysisSummary() {
    Column() {
      Text('分析结果')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 16 })
      
      Row() {
        Column() {
          Text('性别')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getGenderText())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text('年龄')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getAgeText())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text('关系')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getRelationshipText())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      
      if (this.targetProfile.interests.length > 0) {
        Column() {
          Text('兴趣爱好')
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 16, bottom: 8 })
          
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.getSelectedInterests(), (interest: InterestTag) => {
              Text(interest.name)
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor(interest.color)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .margin({ right: 8, bottom: 8 })
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 8, bottom: 16 })
  }

  @Builder
  buildRecommendedGifts() {
    Column() {
      Row() {
        Text('推荐礼物')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text(`共${this.recommendedGifts.length}件`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#4CAF50')
          
          Text('正在分析推荐...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.recommendedGifts, (gift: Gift) => {
            ListItem() {
              this.buildGiftCard(gift)
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildGiftCard(gift: Gift) {
    Row() {
      // 礼物图片占位
      Column() {
        Text('🎁')
          .fontSize(32)
      }
      .width(80)
      .height(80)
      .backgroundColor('#F0F0F0')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      
      // 礼物信息
      Column() {
        Text(gift.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(gift.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
        
        Row() {
          Text(`¥${gift.price}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
          
          Blank()
          
          Row() {
            Text('⭐')
              .fontSize(12)
            Text(`${gift.rating}`)
              .fontSize(12)
              .fontColor('#666666')
            Text(`(${gift.reviewCount})`)
              .fontSize(10)
              .fontColor('#999999')
          }
        }
        .width('100%')
        .margin({ top: 8 })
        
        // 推荐理由
        if (gift.meaning) {
          Text(`💡 ${gift.meaning}`)
            .fontSize(10)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      // 点击查看礼物详情
      console.log('查看礼物详情:', gift.name);
    })
  }

  private canProceed(): boolean {
    switch (this.currentStep) {
      case 1:
        return this.targetProfile.gender !== undefined;
      case 2:
        return this.targetProfile.ageRange !== undefined;
      case 3:
        return this.targetProfile.relationship !== undefined;
      case 4:
        return this.targetProfile.interests.length > 0;
      default:
        return false;
    }
  }

  private startAnalysis() {
    this.loading = true;
    this.showResults = true;
    
    // 模拟分析过程
    setTimeout(() => {
      const request: GiftRecommendationRequest = {
        targetGroup: {
          gender: this.targetProfile.gender || Gender.UNISEX,
          ageRange: this.targetProfile.ageRange || AgeRange.ADULT,
          relationship: this.targetProfile.relationship || Relationship.FRIEND,
          interests: []
        }
      };
      const response = this.giftService.getRecommendations(request);
      this.recommendedGifts = response.gifts;
      this.loading = false;
    }, 1500);
  }

  private getGenderText(): string {
    switch (this.targetProfile.gender) {
      case Gender.MALE:
        return '男性';
      case Gender.FEMALE:
        return '女性';
      default:
        return '未选择';
    }
  }

  private getAgeText(): string {
    switch (this.targetProfile.ageRange) {
      case AgeRange.CHILD:
        return '儿童';
      case AgeRange.TEEN:
        return '青少年';
      case AgeRange.YOUNG_ADULT:
        return '青年';
      case AgeRange.ADULT:
        return '成年';
      case AgeRange.SENIOR:
        return '老年';
      default:
        return '未选择';
    }
  }

  private getRelationshipText(): string {
    switch (this.targetProfile.relationship) {
      case Relationship.ROMANTIC:
        return '恋人';
      case Relationship.FAMILY:
        return '家人';
      case Relationship.FRIEND:
        return '朋友';
      case Relationship.COLLEAGUE:
        return '同事';
      case Relationship.TEACHER:
        return '老师';
      case Relationship.BOSS:
        return '老板';
      case Relationship.ACQUAINTANCE:
        return '熟人';
      default:
        return '未选择';
    }
  }

  private getSelectedInterests(): InterestTag[] {
    return this.interestTags.filter(tag => this.targetProfile.interests.includes(tag.id));
  }
}
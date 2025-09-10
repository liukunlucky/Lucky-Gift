import router from '@ohos.router';

interface Holiday {
  id: string;
  name: string;
  date: string; // YYYY-MM-DD format
  icon: string;
  color: string;
  description: string;
  isAnnual: boolean; // 是否每年重复
}

interface CountdownInfo {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
  isPast: boolean;
}

@Entry
@Component
struct HolidayCountdownPage {
  @State holidays: Holiday[] = [];
  @State currentTime: number = Date.now();
  private timer: number = -1;
  
  aboutToAppear() {
    this.loadHolidays();
    this.startTimer();
  }
  
  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }
  
  loadHolidays() {
    const currentYear = new Date().getFullYear();
    const nextYear = currentYear + 1;
    
    this.holidays = [
      {
        id: '1',
        name: '春节',
        date: `${nextYear}-02-10`, // 2025年春节
        icon: '🧧',
        color: '#F44336',
        description: '中国传统新年，阖家团圆的重要节日',
        isAnnual: true
      },
      {
        id: '2',
        name: '情人节',
        date: `${nextYear}-02-14`,
        icon: '💕',
        color: '#E91E63',
        description: '浪漫的爱情节日，表达爱意的好时机',
        isAnnual: true
      },
      {
        id: '3',
        name: '妇女节',
        date: `${nextYear}-03-08`,
        icon: '🌸',
        color: '#9C27B0',
        description: '向身边的女性表达关爱和感谢',
        isAnnual: true
      },
      {
        id: '4',
        name: '母亲节',
        date: `${nextYear}-05-11`, // 2025年母亲节（5月第二个周日）
        icon: '🌹',
        color: '#FF9800',
        description: '感恩母亲，表达对母爱的感激',
        isAnnual: true
      },
      {
        id: '5',
        name: '儿童节',
        date: `${nextYear}-06-01`,
        icon: '🎈',
        color: '#4CAF50',
        description: '属于孩子们的快乐节日',
        isAnnual: true
      },
      {
        id: '6',
        name: '父亲节',
        date: `${nextYear}-06-15`, // 2025年父亲节（6月第三个周日）
        icon: '👔',
        color: '#2196F3',
        description: '向父亲表达敬意和感谢的节日',
        isAnnual: true
      },
      {
        id: '7',
        name: '中秋节',
        date: `${nextYear}-10-06`, // 2025年中秋节
        icon: '🥮',
        color: '#FF9800',
        description: '团圆佳节，赏月品月饼',
        isAnnual: true
      },
      {
        id: '8',
        name: '万圣节',
        date: `${nextYear}-10-31`,
        icon: '🎃',
        color: '#FF5722',
        description: '神秘有趣的西方节日',
        isAnnual: true
      },
      {
        id: '9',
        name: '感恩节',
        date: `${nextYear}-11-27`, // 2025年感恩节（11月第四个周四）
        icon: '🦃',
        color: '#8BC34A',
        description: '感恩身边的人和事',
        isAnnual: true
      },
      {
        id: '10',
        name: '圣诞节',
        date: `${nextYear}-12-25`,
        icon: '🎄',
        color: '#4CAF50',
        description: '充满温馨和祝福的节日',
        isAnnual: true
      }
    ];
    
    // 按日期排序
    this.holidays.sort((a, b) => {
      const dateA = new Date(a.date).getTime();
      const dateB = new Date(b.date).getTime();
      return dateA - dateB;
    });
  }
  
  startTimer() {
    this.timer = setInterval(() => {
      this.currentTime = Date.now();
    }, 1000);
  }
  
  getCountdown(holiday: Holiday): CountdownInfo {
    const targetDate = new Date(holiday.date).getTime();
    const now = this.currentTime;
    const diff = targetDate - now;
    
    if (diff <= 0) {
      return {
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0,
        isPast: true
      };
    }
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);
    
    return {
      days,
      hours,
      minutes,
      seconds,
      isPast: false
    };
  }
  
  getUpcomingHolidays(): Holiday[] {
    return this.holidays.filter(holiday => {
      const countdown = this.getCountdown(holiday);
      return !countdown.isPast;
    }).slice(0, 3); // 只显示最近的3个节日
  }
  
  formatCountdownText(countdown: CountdownInfo): string {
    if (countdown.isPast) {
      return '已过期';
    }
    
    if (countdown.days > 0) {
      return `${countdown.days}天 ${countdown.hours}小时`;
    } else if (countdown.hours > 0) {
      return `${countdown.hours}小时 ${countdown.minutes}分钟`;
    } else {
      return `${countdown.minutes}分 ${countdown.seconds}秒`;
    }
  }
  
  getCountdownStatus(countdown: CountdownInfo): string {
    if (countdown.isPast) {
      return '已过期';
    }
    
    if (countdown.days === 0 && countdown.hours === 0 && countdown.minutes < 60) {
      return '即将到来';
    } else if (countdown.days === 0) {
      return '今天';
    } else if (countdown.days === 1) {
      return '明天';
    } else if (countdown.days <= 7) {
      return '本周';
    } else if (countdown.days <= 30) {
      return '本月';
    } else {
      return '较远';
    }
  }
  
  getStatusColor(countdown: CountdownInfo): string {
    if (countdown.isPast) {
      return '#999999';
    }
    
    if (countdown.days === 0) {
      return '#F44336'; // 红色 - 今天
    } else if (countdown.days <= 7) {
      return '#FF9800'; // 橙色 - 一周内
    } else if (countdown.days <= 30) {
      return '#4CAF50'; // 绿色 - 一月内
    } else {
      return '#2196F3'; // 蓝色 - 较远
    }
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
              .fontSize(20)
              .fontColor('#333333')
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text('节日倒计时')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row()
          .width(40)
          .height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      Scroll() {
        Column() {
          // 即将到来的节日
          Column() {
            Text('即将到来')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 20 })
            
            ForEach(this.getUpcomingHolidays(), (holiday: Holiday, index: number) => {
              
              Column() {
                Row() {
                  // 节日图标和信息
                  Row() {
                    Text(holiday.icon)
                      .fontSize(32)
                      .margin({ right: 16 })
                    
                    Column() {
                      Text(holiday.name)
                        .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .alignSelf(ItemAlign.Start)
                      
                      Text(holiday.description)
                        .fontSize(14)
                        .fontColor('#666666')
                        .alignSelf(ItemAlign.Start)
                        .margin({ top: 4 })
                      
                      Text(holiday.date)
                        .fontSize(12)
                        .fontColor('#999999')
                        .alignSelf(ItemAlign.Start)
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)
                  
                  // 倒计时信息
                  Column() {
                    Text(this.formatCountdownText(this.getCountdown(holiday)))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.getStatusColor(this.getCountdown(holiday)))
                      .textAlign(TextAlign.Center)
                    
                    Text(this.getCountdownStatus(this.getCountdown(holiday)))
                      .fontSize(12)
                      .fontColor(this.getStatusColor(this.getCountdown(holiday)))
                      .textAlign(TextAlign.Center)
                      .margin({ top: 4 })
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor(this.getStatusColor(this.getCountdown(holiday)) + '20')
                      .borderRadius(10)
                  }
                  .alignItems(HorizontalAlign.Center)
                }
                .width('100%')
                .padding(20)
                .alignItems(VerticalAlign.Center)
                
                // 详细倒计时（仅对最近的节日显示）
                if (index === 0 && !this.getCountdown(holiday).isPast) {
                  Row() {
                    // 天数
                    Column() {
                      Text(this.getCountdown(holiday).days.toString())
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(holiday.color)
                      
                      Text('天')
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    
                    Text(':')
                      .fontSize(20)
                      .fontColor('#CCCCCC')
                      .margin({ left: 8, right: 8 })
                    
                    // 小时
                    Column() {
                      Text(this.getCountdown(holiday).hours.toString().padStart(2, '0'))
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(holiday.color)
                      
                      Text('小时')
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    
                    Text(':')
                      .fontSize(20)
                      .fontColor('#CCCCCC')
                      .margin({ left: 8, right: 8 })
                    
                    // 分钟
                    Column() {
                      Text(this.getCountdown(holiday).minutes.toString().padStart(2, '0'))
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(holiday.color)
                      
                      Text('分钟')
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    
                    Text(':')
                      .fontSize(20)
                      .fontColor('#CCCCCC')
                      .margin({ left: 8, right: 8 })
                    
                    // 秒数
                    Column() {
                      Text(this.getCountdown(holiday).seconds.toString().padStart(2, '0'))
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(holiday.color)
                      
                      Text('秒')
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                  }
                  .width('100%')
                  .padding({ left: 20, right: 20, bottom: 20 })
                  .justifyContent(FlexAlign.Center)
                }
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ bottom: 16 })
              .shadow({
                radius: 8,
                color: '#1A000000',
                offsetX: 0,
                offsetY: 2
              })
            })
          }
          .width('100%')
          .margin({ bottom: 24 })
          
          // 全年节日列表
          Column() {
            Text('全年节日')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            Column() {
              ForEach(this.holidays, (holiday: Holiday) => {
                
                Row() {
                  Text(holiday.icon)
                    .fontSize(20)
                    .margin({ right: 12 })
                  
                  Column() {
                    Text(holiday.name)
                      .fontSize(16)
                      .fontColor('#333333')
                      .alignSelf(ItemAlign.Start)
                    
                    Text(holiday.date)
                      .fontSize(12)
                      .fontColor('#999999')
                      .alignSelf(ItemAlign.Start)
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  
                  Text(this.getCountdown(holiday).isPast ? '已过期' : `${this.getCountdown(holiday).days}天后`)
                    .fontSize(14)
                    .fontColor(this.getCountdown(holiday).isPast ? '#999999' : this.getStatusColor(this.getCountdown(holiday)))
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .padding({ top: 12, bottom: 12 })
                .alignItems(VerticalAlign.Center)
                .border({ width: { bottom: 1 }, color: '#F0F0F0' })
              })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
          }
          .width('100%')
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
}
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface PersonBudget {
  id: string;
  name: string;
  budget: number;
  allocatedAmount: number;
}

@Entry
@Component
struct BudgetCalculatorPage {
  @State private totalBudget: number = 0;
  @State private peopleCount: number = 1;
  @State private people: PersonBudget[] = [];
  @State private currentPersonName: string = '';
  @State private showEditPersonDialog: boolean = false;
  @State private showAddPersonDialog: boolean = false;
  @State private editingPersonId: string = '';

  
  aboutToAppear() {
    this.initializePeople();
  }
  
  initializePeople() {
    // 初始化一个人的预算分配
    this.people = [{
      id: '1',
      name: '成员1',
      budget: 0,
      allocatedAmount: 0
    }];
  }
  

  
  // 增加人数
  increasePeopleCount() {
    if (this.peopleCount >= 20) {
      promptAction.showToast({
        message: '最多支持20人',
        duration: 2000
      });
      return;
    }
    this.peopleCount++;
    this.updatePeopleList();
  }
  
  // 减少人数
  decreasePeopleCount() {
    if (this.peopleCount <= 1) {
      promptAction.showToast({
        message: '至少需要1人',
        duration: 2000
      });
      return;
    }
    this.peopleCount--;
    this.updatePeopleList();
  }
  
  // 更新人员列表
  private updatePeopleList(): void {
    // 调整人员列表
    while (this.people.length < this.peopleCount) {
      const newPerson: PersonBudget = {
        id: Date.now().toString() + this.people.length,
        name: `成员${this.people.length + 1}`,
        budget: 0,
        allocatedAmount: 0
      };
      this.people.push(newPerson);
    }
    
    // 移除多余的人员
    while (this.people.length > this.peopleCount) {
      this.people.pop();
    }
    
    }
  
  // 更新人员预算
  updatePersonBudget(personId: string, amount: number) {
    const person = this.people.find(p => p.id === personId);
    if (person) {
      person.budget = amount;
    }
  }
  
  // 保存人员信息
  savePerson() {
    if (this.currentPersonName.trim() === '') {
      promptAction.showToast({
        message: '请输入成员名称',
        duration: 2000
      });
      return;
    }
    
    if (this.editingPersonId) {
      // 编辑现有人员 - 使用响应式更新方法
      const updatedPeople: PersonBudget[] = [];
      for (const person of this.people) {
        if (person.id === this.editingPersonId) {
          const updatedPerson: PersonBudget = {
            id: person.id,
            name: this.currentPersonName,
            budget: person.budget,
            allocatedAmount: person.allocatedAmount
          };
          updatedPeople.push(updatedPerson);
        } else {
          updatedPeople.push(person);
        }
      }
      this.people = updatedPeople;
      this.showEditPersonDialog = false;
    } else {
      // 添加新人员
      const newPerson: PersonBudget = {
        id: Date.now().toString(),
        name: this.currentPersonName,
        budget: 0,
        allocatedAmount: 0
      };
      this.people.push(newPerson);
      this.peopleCount = this.people.length;
      this.showAddPersonDialog = false;
    }
    
    this.currentPersonName = '';
    this.editingPersonId = '';
  }
  
  // 删除人员
  deletePerson(personId: string) {
    const index = this.people.findIndex(person => person.id === personId);
    if (index > -1) {
      this.people.splice(index, 1);
      this.peopleCount = this.people.length;
    }
  }
  
  // 更新人员分配金额
  updatePersonAllocation(personId: string, amount: number) {
    const updatedPeople: PersonBudget[] = [];
    for (const person of this.people) {
      if (person.id === personId) {
        const updatedPerson: PersonBudget = {
          id: person.id,
          name: person.name,
          budget: person.budget,
          allocatedAmount: amount
        };
        updatedPeople.push(updatedPerson);
      } else {
        updatedPeople.push(person);
      }
    }
    this.people = updatedPeople;
  }
  


  // 显示编辑人员对话框
  private showEditDialog(person: PersonBudget): void {
    this.currentPersonName = person.name;
    this.editingPersonId = person.id;
    this.showEditPersonDialog = true;
  }
  
  // 重置预算
  resetBudget() {
    this.totalBudget = 0;
    this.peopleCount = 1;
    this.people = [];
    this.initializePeople();
  }

  // 获取总分配金额
  getTotalAllocated(): number {
    return this.people.reduce((total, person) => total + person.allocatedAmount, 0);
  }

  // 获取剩余预算
  getRemainingBudget(): number {
    return this.totalBudget - this.getTotalAllocated();
  }

  // 获取分配进度
  getAllocationProgress(): number {
    if (this.totalBudget === 0) return 0;
    return (this.getTotalAllocated() / this.totalBudget) * 100;
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
        
        Text('预算计算器')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Text('重置')
            .fontSize(14)
            .fontColor('#FF4444')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.resetBudget();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      Scroll() {
        Column() {
          // 总预算设置
          Column() {
            Text('总预算设置')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            Row() {
              Text('¥')
                .fontSize(24)
                .fontColor('#FF6B35')
                .fontWeight(FontWeight.Bold)
              
              TextInput({ placeholder: '点击输入总预算金额' })
                .type(InputType.Number)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .layoutWeight(1)
                .placeholderColor('#FFB399')
                .placeholderFont({ size: 20 })
                .onChange((value: string) => {
              this.totalBudget = parseFloat(value) || 0;
            })
            }
            .width('100%')
            .height(60)
            .backgroundColor('#FFF5F0')
            .borderRadius(12)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 16 })
          
          // 人数设置
          Column() {
            Text('参与人数')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            Row() {
              Button() {
                Text('-')
                  .fontSize(20)
                  .fontColor('#FF6B35')
                  .fontWeight(FontWeight.Bold)
              }
              .width(40)
              .height(40)
              .backgroundColor('#FFF5F0')
              .borderRadius(8)
              .onClick(() => {
                if (this.peopleCount > 1) {
                  this.peopleCount--;
                  this.updatePeopleList();
                } else {
                  promptAction.showToast({
                    message: '至少需要1个人参与预算分配',
                    duration: 2000
                  });
                }
              })
              
              Text(this.peopleCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              
              Button() {
                Text('+')
                  .fontSize(20)
                  .fontColor('#FF6B35')
                  .fontWeight(FontWeight.Bold)
              }
              .width(40)
              .height(40)
              .backgroundColor('#FFF5F0')
              .borderRadius(8)
              .onClick(() => {
                if (this.peopleCount < 10) {
                  this.peopleCount++;
                  this.updatePeopleList();
                }
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            
            // 预算概览
            Row() {
              Column() {
                Text('总预算')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ bottom: 4 })
                
                Text(`¥${this.totalBudget.toFixed(2)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              

            }
            .width('100%')
            .padding(10)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 16 })
          
          // 预算概览
          Column() {
            Text('预算概览')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            // 总体统计
            Row() {
              Column() {
                Text('总预算')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })
                
                Text(`¥${this.totalBudget}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              
              Column() {
                Text('已分配')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })
                
                Text(`¥${this.getTotalAllocated()}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2196F3')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              
              Column() {
                Text('剩余')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })
                
                Text(`¥${this.getRemainingBudget()}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getRemainingBudget() >= 0 ? '#4CAF50' : '#F44336')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 分配进度条
            Column() {
              Row() {
                Text('分配进度')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Blank()
                
                Text(`${this.getAllocationProgress().toFixed(1)}%`)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ bottom: 8 })
              
              if (this.getTotalAllocated() > this.totalBudget) {
                Row() {
                  Image($r('app.media.ic_warning'))
                    .width(14)
                    .height(14)
                    .fillColor('#F44336')
                    .margin({ right: 4 })
                  
                  Text('分配金额超出预算')
                    .fontSize(12)
                    .fontColor('#F44336')
                }
                .alignItems(VerticalAlign.Center)
                .margin({ top: 4 })
              }
              
              Progress({
                value: this.getTotalAllocated(),
                total: this.totalBudget || 1,
                type: ProgressType.Linear
              })
                .width('100%')
                .height(8)
                .color(this.getTotalAllocated() > this.totalBudget ? '#F44336' : '#2196F3')
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 16 })
          
          // 人员分配
          Column() {
            Row() {
              Text('人员分配')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            if (this.people.length === 0) {
              Column() {
                Text('👥')
                  .fontSize(60)
                  .fontColor('#CCCCCC')
                
                Text('还没有参与人员')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 16 })
                
                Text('设置人数或添加人员开始分配预算')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              // 人员列表
              Column() {
                ForEach(this.people, (person: PersonBudget, index: number) => {
                  Column() {
                    Row() {
                      Text('👤')
                        .fontSize(20)
                        .margin({ right: 12 })
                      
                      Column() {
                        Text(person.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .alignSelf(ItemAlign.Start)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                      Image($r('app.media.icon_edit'))
                        .width(18)
                        .height(18)
                        .fillColor('#333333')
                        .visibility(Visibility.None)
                        .onClick(() => this.showEditDialog(person))
                        .margin({ right: 4 })
                      
                      if (this.people.length > 1) {
                        Image($r('app.media.icon_delete'))
                          .width(22)
                          .height(22)
                          .fillColor(Color.Red)
                          .margin({ left: 4 })
                          .onClick(() => this.deletePerson(person.id))
                       }
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 12 })

                    // 分配金额滑动条
                    Column() {
                      TextInput({
                        text: person.allocatedAmount.toString(),
                        placeholder: '¥ 请输入分配金额'
                      })
                        .width('100%')
                        .height(48)
                        .type(InputType.Number)
                        .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#FF6B35')
                        .backgroundColor('#FFF5F0')
                        .borderRadius(10)
                        .padding({ left: 16, right: 16 })
                        .placeholderColor('#FFB399')
                        .placeholderFont({ size: 16 })
                        .border({ width: 0 })
                        .onChange((value: string) => {
                          const amount = parseFloat(value) || 0;
                          this.updatePersonAllocation(person.id, amount);
                        })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .margin({ bottom: 12 })
                }, (person: PersonBudget) => person.id)
              }
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
      
      // 添加/编辑人员对话框
      if (this.showEditPersonDialog) {
        Stack() {
          // 背景遮罩
          Rect()
            .width('100%')
            .height('100%')
            .fill('#80000000')
            .onClick(() => {
              this.showEditPersonDialog = false;
            })
          
          // 对话框内容
          Column() {
            Text(this.editingPersonId ? '编辑人员' : '添加人员')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 20 })
            
            // 人员姓名
            Column() {
              Text('姓名')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              TextInput({ placeholder: '点击输入姓名', text: this.currentPersonName })
                .fontSize(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .borderWidth(2)
                .borderColor('#FF6B35')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .placeholderColor('#CCCCCC')
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.currentPersonName = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 24 })
            
            // 按钮
            Row() {
              Button('取消')
                .fontSize(16)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.showEditPersonDialog = false;
                })
              
              Button('保存')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF6B35')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => this.savePerson())
            }
            .width('100%')
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
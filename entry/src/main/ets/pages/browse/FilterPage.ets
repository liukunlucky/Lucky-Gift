import router from '@ohos.router';

interface PriceRange {
  min: number;
  max: number;
}

interface FilterOptions {
  categories: string[];
  priceRange: PriceRange;
  occasions: string[];
  relationships: string[];
  styles: string[];
}

@Entry
@Component
struct FilterPage {
  @State selectedCategories: string[] = [];
  @State selectedOccasions: string[] = [];
  @State selectedRelationships: string[] = [];
  @State selectedStyles: string[] = [];
  @State minPrice: number = 0;
  @State maxPrice: number = 10000;

  private categories: string[] = ['数码产品', '美妆护肤', '服装配饰', '家居用品', '运动户外', '图书文具', '美食特产', '手工艺品'];
  private occasions: string[] = ['生日', '情人节', '母亲节', '父亲节', '圣诞节', '新年', '毕业', '结婚', '升职', '搬家'];
  private relationships: string[] = ['恋人', '配偶', '父母', '子女', '兄弟姐妹', '朋友', '同事', '老师', '同学', '长辈'];
  private styles: string[] = ['实用型', '浪漫型', '创意型', '奢华型', '简约型', '复古型', '科技型', '手工型'];

  aboutToAppear() {
    const params = router.getParams() as FilterOptions | null;
    if (params) {
      this.selectedCategories = params.categories || [];
      this.selectedOccasions = params.occasions || [];
      this.selectedRelationships = params.relationships || [];
      this.selectedStyles = params.styles || [];
      this.minPrice = params.priceRange?.min || 0;
      this.maxPrice = params.priceRange?.max || 10000;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .backgroundColor(Color.Transparent)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })

        Text('筛选条件')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('确定')
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            this.applyFilters();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          // 分类筛选
          this.FilterSection('礼物分类', this.categories, this.selectedCategories)

          // 价格范围
          this.PriceRangeSection()

          // 场合筛选
          this.FilterSection('适用场合', this.occasions, this.selectedOccasions)

          // 关系筛选
          this.FilterSection('关系类型', this.relationships, this.selectedRelationships)

          // 风格筛选
          this.FilterSection('礼物风格', this.styles, this.selectedStyles)
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 底部操作栏
      Row() {
        Button('重置')
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .width('30%')
          .onClick(() => {
            this.resetFilters();
          })

        Button('应用筛选')
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .width('65%')
          .onClick(() => {
            this.applyFilters();
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FilterSection(title: string, options: string[], selectedOptions: string[]) {
    Column({ space: 12 }) {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(options, (option: string) => {
          Button(option)
            .fontSize(14)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(selectedOptions.includes(option) ? '#007AFF' : '#F0F0F0')
            .fontColor(selectedOptions.includes(option) ? Color.White : '#333333')
            .onClick(() => {
              this.toggleSelection(selectedOptions, option);
            })
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  PriceRangeSection() {
    Column({ space: 12 }) {
      Row() {
        Text('价格范围')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Row() {
        TextInput({ placeholder: '最低价格', text: this.minPrice.toString() })
          .width('45%')
          .type(InputType.Number)
          .onChange((value: string) => {
            this.minPrice = parseInt(value) || 0;
          })

        Text('至')
          .fontSize(14)
          .fontColor('#666666')
          .width('10%')
          .textAlign(TextAlign.Center)

        TextInput({ placeholder: '最高价格', text: this.maxPrice.toString() })
          .width('45%')
          .type(InputType.Number)
          .onChange((value: string) => {
            this.maxPrice = parseInt(value) || 10000;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Button('0-100')
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.minPrice = 0;
            this.maxPrice = 100;
          })

        Button('100-500')
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.minPrice = 100;
            this.maxPrice = 500;
          })

        Button('500-1000')
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.minPrice = 500;
            this.maxPrice = 1000;
          })

        Button('1000+')
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.minPrice = 1000;
            this.maxPrice = 10000;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  private toggleSelection(selectedArray: string[], item: string) {
    const index = selectedArray.indexOf(item);
    if (index > -1) {
      selectedArray.splice(index, 1);
    } else {
      selectedArray.push(item);
    }
  }

  private resetFilters() {
    this.selectedCategories = [];
    this.selectedOccasions = [];
    this.selectedRelationships = [];
    this.selectedStyles = [];
    this.minPrice = 0;
    this.maxPrice = 10000;
  }

  private applyFilters() {
    const priceRange: PriceRange = { min: this.minPrice, max: this.maxPrice };
    const filterOptions: FilterOptions = {
      categories: this.selectedCategories,
      priceRange: priceRange,
      occasions: this.selectedOccasions,
      relationships: this.selectedRelationships,
      styles: this.selectedStyles
    };

    router.back({
      url: 'pages/tabs/BrowsePage',
      params: filterOptions
    });
  }
}
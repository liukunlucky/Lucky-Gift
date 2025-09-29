# use context7
# 你是一个资深的程序员，精通多种编程语言和开发工具。你的任务是帮助开发者开发鸿蒙app。鸿蒙app开发使用的是arkTs语言，在context7中已经有这部分语言特性，名字叫`Arkts Rag`。如果你没找到，可以参考下面。每次写完用`hvigorw assembleHap --mode module -p product=default -p buildMode=debug`这个命令执行编译，有问题就继续修复并再次执行，直到没有编译错误。

# 每次新增页面都要放到‘main_page.json’中
# arkTs代码片段
================
CODE SNIPPETS
================
TITLE: Marquee Component Example | ArkTS
DESCRIPTION: A complete ArkTS example demonstrating the Marquee component's functionality. It includes setting properties like start, step, loop, fromStart, src, and marqueeUpdateStrategy. It also shows how to use event callbacks like onStart, onBounce, and onFinish, along with styling and dynamic updates.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-marquee.md#_snippet_12

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct MarqueeExample {
  @State start: boolean = false;
  @State src: string = '';
  @State marqueeText: string = 'Running Marquee';
  private fromStart: boolean = true;
  private step: number = 10;
  private loop: number = Number.POSITIVE_INFINITY;
  controller: TextClockController = new TextClockController();

  convert2time(value: number): string {
    let date = new Date(Number(value + '000'));
    let hours = date.getHours().toString().padStart(2, '0');
    let minutes = date.getMinutes().toString().padStart(2, '0');
    let seconds = date.getSeconds().toString().padStart(2, '0');
    return hours + ":" + minutes + ":" + seconds;
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Marquee({
        start: this.start,
        step: this.step,
        loop: this.loop,
        fromStart: this.fromStart,
        src: this.marqueeText + this.src
      })
        .marqueeUpdateStrategy(MarqueeUpdateStrategy.PRESERVE_POSITION)
        .width('300vp')
        .height('80vp')
        .fontColor('#FFFFFF')
        .fontSize('48fp')
        .allowScale(true) // 当fontSize为‘fp’单位且想要Marquee组件文本跟随系统字体大小缩放，可以设置该属性为true
        .fontWeight(700)
        .fontFamily('HarmonyOS Sans') // 不想跟随主题字体可设置该属性为默认字体'HarmonyOS Sans'
        .backgroundColor('#182431')
        .margin({ bottom: '40vp' })
        .onStart(() => {
          console.info('Succeeded in completing the onStart callback of marquee animation');
        })
        .onBounce(() => {
          console.info('Succeeded in completing the onBounce callback of marquee animation');
        })
        .onFinish(() => {
          console.info('Succeeded in completing the onFinish callback of marquee animation');
        })
      Button('Start')
        .onClick(() => {
          this.start = true
          // 启动文本时钟
          this.controller.start();
        })
        .width('120vp')
        .height('40vp')
        .fontSize('16fp')
        .fontWeight(500)
        .backgroundColor('#007DFF')
      TextClock({ timeZoneOffset: -8, controller: this.controller })
        .format('hms')
        .onDateChange((value: number) => {
          this.src = this.convert2time(value);
        })
        .margin('20vp')
        .fontSize('30fp')
    }
    .width('100%')
    .height('100%')
  }
}
```

--------------------------------

TITLE: ImageSpan Examples
DESCRIPTION: Code examples demonstrating the usage of the ImageSpan component, including setting alignment and background styles.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-imagespan.md#_snippet_16

LANGUAGE: APIDOC
CODE:
```
## Examples

### Example 1 (Setting Alignment)

从API version 10开始，该示例通过[verticalAlign](#verticalalign)、[objectFit](#objectfit)属性展示了ImageSpan组件的对齐方式以及缩放效果。

```ts
// xxx.ets
@Entry
@Component
struct SpanExample {
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Text() {
        Span('This is the Span and ImageSpan component').fontSize(25).textCase(TextCase.Normal)
          .decoration({ type: TextDecorationType.None, color: Color.Pink })
      }.width('100%').textAlign(TextAlign.Center)

      Text() {
        // $r('app.media.app_icon')需要替换为开发者所需的图像资源文件。
        ImageSpan($r('app.media.app_icon'))
          .width('200px')
          .height('200px')
          .objectFit(ImageFit.Fill)
          .verticalAlign(ImageSpanAlignment.CENTER)
        Span('I am LineThrough-span')
          .decoration({ type: TextDecorationType.LineThrough, color: Color.Red }).fontSize(25)
        ImageSpan($r('app.media.app_icon'))
          .width('50px')
          .height('50px')
          .verticalAlign(ImageSpanAlignment.TOP)
        Span('I am Underline-span')
          .decoration({ type: TextDecorationType.Underline, color: Color.Red }).fontSize(25)
        ImageSpan($r('app.media.app_icon'))
          .size({ width: '100px', height: '100px' })
          .verticalAlign(ImageSpanAlignment.BASELINE)
        Span('I am Underline-span')
          .decoration({ type: TextDecorationType.Underline, color: Color.Red }).fontSize(25)
        ImageSpan($r('app.media.app_icon'))
          .width('70px')
          .height('70px')
          .verticalAlign(ImageSpanAlignment.BOTTOM)
        Span('I am Underline-span')
          .decoration({ type: TextDecorationType.Underline, color: Color.Red }).fontSize(50)
      }
      .width('100%')
      .textIndent(50)
    }.width('100%').height('100%').padding({ left: 0, right: 0, top: 0 })
  }
}
```

![imagespan](figures/imagespan.png)

### Example 2 (Setting Background Style)

从API version 11开始，该示例通过[textBackgroundStyle](ts-basic-components-span.md#textbackgroundstyle11)属性展示了文本设置背景样式的效果。

```ts
// xxx.ets
@Component
@Entry
struct Index {
  build() {
    Row() {
      Column() {
        Text() {
          // $r('app.media.sky')需要替换为开发者所需的图像资源文件。
          ImageSpan($r('app.media.sky'))
            .width('60vp')
            .height('60vp')
            .verticalAlign(ImageSpanAlignment.CENTER)
            .borderRadius(20)
            .textBackgroundStyle({ color: '#7F007DFF', radius: "5vp" })
        }
      }.width('100%')
    }.height('100%')
  }
}
```
![imagespan](figures/image_span_textbackgroundstyle.png)
```

--------------------------------

TITLE: Basic ListItem Creation Example
DESCRIPTION: Example demonstrating the basic usage of creating a ListItem.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-listitem.md#_snippet_22

LANGUAGE: APIDOC
CODE:
```
## Example 1: Creating a ListItem

### Description
This example implements the basic usage of creating a ListItem.

### Code
```ts
// xxx.ets
export class ListDataSource implements IDataSource {
  private list: number[] = [];

  constructor(list: number[]) {
    this.list = list;
  }

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): number {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}

@Entry
@Component
struct ListItemExample {
  private arr: ListDataSource = new ListDataSource([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  build() {
    Column() {
      List({ space: 20, initialIndex: 0 }) {
        LazyForEach(this.arr, (item: number) => {
          ListItem() {
            Text('' + item)
              .width('100%')
              .height(100)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .borderRadius(10)
              .backgroundColor(0xFFFFFF)
          }
        }, (item: string) => item)
      }.width('90%')
      .scrollBar(BarState.Off)
    }.width('100%').height('100%').backgroundColor(0xDCDCDC).padding({ top: 5 })
  }
}
```
```

--------------------------------

TITLE: Example 1: Setting and Getting Cursor Position
DESCRIPTION: Demonstrates how to set and retrieve the cursor's position in a TextArea using the controller.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-textarea.md#_snippet_94

LANGUAGE: APIDOC
CODE:
```
### Example 1: Setting and Getting Cursor Position

Starting from API version 8, this example uses the [controller](#textareacontroller8) to set and get the cursor position.

```ts
// xxx.ets
@Entry
@Component
struct TextAreaExample {
  @State text: string = '';
  @State positionInfo: CaretOffset = { index: 0, x: 0, y: 0 };
  controller: TextAreaController = new TextAreaController();

  build() {
    Column() {
      TextArea({
        text: this.text,
        placeholder: 'The text area can hold an unlimited amount of text. input your word...', 
        controller: this.controller
      })
        .placeholderFont({ size: 16, weight: 400 })
        .width(336)
        .height(56)
        .margin(20)
        .fontSize(16)
        .fontColor('#182431')
        .backgroundColor('#FFFFFF')
        .onChange((value: string) => {
          this.text = value;
        })
      Text(this.text)
      Button('Set caretPosition 1')
        .backgroundColor('#007DFF')
        .margin(15)
        .onClick(() => {
          // Set cursor position after the first character
          this.controller.caretPosition(1);
        })
      Button('Get CaretOffset')
        .backgroundColor('#007DFF')
        .margin(15)
        .onClick(() => {
          this.positionInfo = this.controller.getCaretOffset();
        })
    }.width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}
```

![textArea](figures/textArea.gif)
```

--------------------------------

TITLE: Example Usage of PopoverOptions
DESCRIPTION: Demonstrates how to use PopoverOptions to create a popover with image and text content, along with primary and secondary buttons.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Dialog.md#_snippet_20

LANGUAGE: APIDOC
CODE:
```
### Example 1: Popover with Image and Text

This example shows a popover displaying an image and text, with 'Cancel' and 'Delete' buttons.

```ts
import { TipsDialog } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  dialogControllerImage: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      imageRes: $r('sys.media.ohos_ic_public_voice'),
      content: '想要卸载这个APP嘛?',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          console.info('Callback when the second button is clicked')
        }
      },
      onCheckedChange: () => {
        console.info('Callback when the checkbox is clicked')
      }
    }),
  })

  build() {
    Row() {
      Stack() {
        Column(){
          Button("上图下文弹出框")
            .width(96)
            .height(40)
            .onClick(() => {
              this.dialogControllerImage.open()
            })
        }.margin({bottom: 300})
      }.align(Alignment.Bottom)
      .width('100%').height('100%')
    }
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
  }
}
```

![TipsDialog](figures/TipsDialogV1.png)
```

--------------------------------

TITLE: Example: Setting and Getting Caret Position
DESCRIPTION: Demonstrates how to set and get the caret position using the SearchController in an ArkTS component. It includes UI elements to trigger these actions and display the results, showcasing the integration of controller methods.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-search.md#_snippet_106

LANGUAGE: typescript
CODE:
```
@Entry
@Component
struct SearchExample {
  @State changeValue: string = '';
  @State submitValue: string = '';
  @State positionInfo: CaretOffset = { index: 0, x: 0, y: 0 };
  controller: SearchController = new SearchController();

  build() {
    Column({space: 10}) {
      Text('onSubmit:' + this.submitValue).fontSize(18).margin(15)
      Text('onChange:' + this.changeValue).fontSize(18).margin(15)
      Search({ value: this.changeValue, placeholder: 'Type to search...', controller: this.controller })
        .searchButton('SEARCH')
        .width('95%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .textFont({ size: 14, weight: 400 })
        .onSubmit((value: string) => {
          this.submitValue = value;
        })
        .onChange((value: string) => {
          this.changeValue = value;
        })
        .margin(20)
      Button('Set caretPosition 1')
        .onClick(() => {
          // 设置光标位置到输入的第一个字符后
          this.controller.caretPosition(1);
        })
      Button('Get CaretOffset')
        .onClick(() => {
          this.positionInfo = this.controller.getCaretOffset();
        })
    }.width('100%')
  }
}
```

--------------------------------

TITLE: Example 1: Basic CalendarPicker with Dropdown
DESCRIPTION: Demonstrates setting up a CalendarPicker with basic configuration, showing a dropdown calendar popup.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-calendarpicker.md#_snippet_16

LANGUAGE: APIDOC
CODE:
```
## Example: Basic CalendarPicker

### Description
This example demonstrates a CalendarPicker component that provides a dropdown calendar popup.

### Code

```ts
// xxx.ets
@Entry
@Component
struct CalendarPickerExample {
  private selectedDate: Date = new Date('2024-03-05');

  build() {
    Column() {
      Column() {
        CalendarPicker({
          hintRadius: 10,
          selected: this.selectedDate
        })
          .edgeAlign(CalendarAlign.END)
          .textStyle({ color: "#ff182431", font: { size: 20, weight: FontWeight.Normal } })
          .margin(10)
          .onChange((value) => {
            console.info(`CalendarPicker onChange: ${value.toString()}`);
          })
      }.alignItems(HorizontalAlign.End).width("100%")

      Text('日历日期选择器').fontSize(30)
    }.width('100%').margin({ top: 350 })
  }
}
```
```

--------------------------------

TITLE: ChipGroup Example
DESCRIPTION: Example demonstrating the usage of ChipGroup without a rightmost builder.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-ChipGroup.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
### Example 1 (Without the rightmost builder)

This example implements the effect when there is no rightmost builder.

```typescript
import { ChipSize, ChipGroup } from '@kit.ArkUI';

@Entry
@Preview
@Component
struct Index {
  @State selected_index: Array<number> = [0, 1, 2, 3, 4, 5, 6];

  build() {
    Column() {
      ChipGroup({
        items: [
          {
            // $r('app.media.icon') needs to be replaced with the developer's required image resource file.
            prefixIcon: { src: $r('app.media.icon') },
            label: { text: 'Operation Block 1' },
            suffixIcon: { src: $r('sys.media.ohos_ic_public_cut') },
            allowClose: false
          },
          {
            prefixIcon: { src: $r('sys.media.ohos_ic_public_copy') },
            label: { text: 'Operation Block 2' },
            allowClose: true
          },
          {
            prefixIcon: { src: $r('sys.media.ohos_ic_public_clock') },
            label: { text: 'Operation Block 3' },
            allowClose: true
          },
          {
            prefixIcon: { src: $r('sys.media.ohos_ic_public_cast_stream') },
            label: { text: 'Operation Block 4' },
            allowClose: true
          },
          {
            prefixIcon: { src: $r('sys.media.ohos_ic_public_cast_mirror') },
            label: { text: 'Operation Block 5' },
            allowClose: true
          },
          {
            prefixIcon: { src: $r('sys.media.ohos_ic_public_cast_stream') },
            label: { text: 'Operation Block 6' },
            allowClose: true
          },
        ],
        itemStyle: {
          size: ChipSize.SMALL,
          backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
          fontColor: $r('sys.color.ohos_id_color_text_primary'),
          selectedBackgroundColor: $r('sys.color.ohos_id_color_emphasize'),
          selectedFontColor: $r('sys.color.ohos_id_color_text_primary_contrary'),
        },
        selectedIndexes: this.selected_index,
        multiple: false,
        chipGroupSpace: { itemSpace: 8, endSpace: 0 },
        chipGroupPadding: { top: 10, bottom: 10 },
        onChange: (activatedChipsIndex: Array<number>) => {
          console.info('chips on clicked, activated index ' + activatedChipsIndex);
        },
      })
    }
  }
}
```

![ChipGroupDemo1](figures/ChipGroupDemo1.png)
```

--------------------------------

TITLE: CalendarPicker Example - Setting Start and End Dates
DESCRIPTION: This example demonstrates how to configure the CalendarPicker to restrict date selection within a specific range by setting the start and end dates. It includes initialization with selected, start, and end dates, along with styling and an event handler.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-calendarpicker.md#_snippet_12

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct CalendarPickerExample {
  private selectedDate: Date = new Date('2025-01-15');
  private startDate: Date = new Date('2025-01-05');
  private endDate: Date = new Date('2025-01-25');

  build() {
    Column() {
      Column() {
        CalendarPicker({ hintRadius: 10, selected: this.selectedDate, start: this.startDate, end: this.endDate })
          .edgeAlign(CalendarAlign.END)
          .textStyle({ color: "#ff182431", font: { size: 20, weight: FontWeight.Normal } })
          .margin(10)
          .onChange((value) => {
            console.info(`CalendarPicker onChange: ${value.toString()}`);
          })
      }.alignItems(HorizontalAlign.End).width("100%")
    }.width('100%').margin({ top: 350 })
  }
}
```

--------------------------------

TITLE: DatePickerDialog Example
DESCRIPTION: Example demonstrating how to use showDatePickerDialog with various options, including Lunar switch styling.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-methods-datepicker-dialog.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
## Example 1 (Setting Display Time)

This example sets the display time using showTime, useMilitaryTime, and dateTimeOptions.

```ts
// xxx.ets
@Entry
@Component
struct DatePickerDialogExample {
  selectedDate: Date = new Date("2010-1-1");

  build() {
    Column() {
      Button("DatePickerDialog")
        .margin(20)
        .onClick(() => {
          this.getUIContext().showDatePickerDialog({
            start: new Date("2000-1-1"),
            end: new Date("2100-12-31"),
            selected: this.selectedDate,
            showTime: true,
            useMilitaryTime: false,
            dateTimeOptions: { hour: "numeric", minute: "2-digit" },
            onDateAccept: (value: Date) => {
              // Save the date when the confirm button is pressed, so that the selected date is displayed when the dialog pops up again.
              this.selectedDate = value;
              console.info("DatePickerDialog:onDateAccept()" + value.toString());
            },
            onCancel: () => {
              console.info("DatePickerDialog:onCancel()")
            },
            onDateChange: (value: Date) => {
              console.info("DatePickerDialog:onDateChange()" + value.toString());
            },
            onDidAppear: () => {
              console.info("DatePickerDialog:onDidAppear()")
            },
            onDidDisappear: () => {
              console.info("DatePickerDialog:onDidDisappear()")
            },
            onWillAppear: () => {
              console.info("DatePickerDialog:onWillAppear()")
            },
            onWillDisappear: () => {
              console.info("DatePickerDialog:onWillDisappear()")
            }
          })
        })
    }.width('100%')
  }
}
```

![DataPickerDialog](figures/DatePickerDialog.gif)
```

--------------------------------

TITLE: Blank Component Examples
DESCRIPTION: Illustrates how to use the Blank component to fill empty space and set minimum widths.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-blank.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
## Blank Component Examples

### Example 1: Filling Empty Space

Demonstrates the effect of the Blank component filling empty space in both portrait and landscape modes.

```typescript
// xxx.ets
@Entry
@Component
struct BlankExample {
  build() {
    Column() {
      Row() {
        Text('Bluetooth').fontSize(18)
        Blank()
        Toggle({ type: ToggleType.Switch }).margin({ top: 14, bottom: 14, left: 6, right: 6 })
      }.width('100%').backgroundColor(0xFFFFFF).borderRadius(15).padding({ left: 12 })
    }.backgroundColor(0xEFEFEF).padding(20)
  }
}
```

Portrait Mode:
![Portrait Mode](figures/zh-cn_image_0000001219662649.gif)

Landscape Mode:
![Landscape Mode](figures/zh-cn_image_0000001174104388.gif)

### Example 2: Filling Fixed Width

Shows the effect of using the `min` parameter when the parent component of the Blank component does not have a width set.

```typescript
// xxx.ets
@Entry
@Component
struct BlankExample {
  build() {
    Column({ space: 20 }) {
      // When the parent component of Blank is not set with width, Blank is ineffective. A minimum width can be set using 'min' to fill a fixed width.
      Row() {
        Text('Bluetooth').fontSize(18)
        Blank().color(Color.Yellow)
        Toggle({ type: ToggleType.Switch }).margin({ top: 14, bottom: 14, left: 6, right: 6 })
      }.backgroundColor(0xFFFFFF).borderRadius(15).padding({ left: 12 })

      Row() {
        Text('Bluetooth').fontSize(18)
        // Set minimum width to 160
        Blank('160').color(Color.Yellow)
        Toggle({ type: ToggleType.Switch }).margin({ top: 14, bottom: 14, left: 6, right: 6 })
      }.backgroundColor(0xFFFFFF).borderRadius(15).padding({ left: 12 })

    }.backgroundColor(0xEFEFEF).padding(20).width('100%')
  }
}
```

When the parent component of Blank is not set with width, there is no blank space between child components. Using the `min` parameter to set the fill size.
![Min Width Fill](figures/blankmin.png)
```

--------------------------------

TITLE: HalfScreenLaunchComponent Usage Example
DESCRIPTION: Demonstrates how to use the HalfScreenLaunchComponent to launch a phone recharge service. It includes setting the appId, handling termination and error callbacks, and passing content via a trailing builder parameter. This example is for ArkUI.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-atomicservice-HalfScreenLaunchComponent.md#_snippet_1

LANGUAGE: typescript
CODE:
```
import { HalfScreenLaunchComponent } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  appId: string = "576****************"; // 原子化服务appId。

  build() {
    Column() {
      HalfScreenLaunchComponent({
        appId: this.appId,
        options: {},
        onTerminated:  (info:TerminationInfo)=> {
          console.info('onTerminated info = '+ info.want);
        },
        onError: (err) => {
          console.error(" onError code: " + err.code + ", message: ", err.message);
        },
        onReceive: (data) => {
          console.info("onReceive, data: " + data['ohos.atomicService.window']);
        }
      }) {
        Column() {
          Image($r('app.media.app_icon'))
          Text('拉起手机充值')
        }.width("80vp").height("80vp").margin({bottom:30})
      } // 通过尾随必包形式传入content。
    }
  }

}
```

--------------------------------

TITLE: GridRow Example
DESCRIPTION: Example demonstrating basic GridRow layout usage with multiple GridCols.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-gridrow.md#_snippet_11

LANGUAGE: APIDOC
CODE:
```
## GridRow Example

### Description
Basic usage example of GridRow layout with responsive columns.

### Code
```ts
// xxx.ets
@Entry
@Component
struct GridRowExample {
  @State bgColors: Color[] = [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown]
  @State currentBp: string = 'unknown'

  build() {
    Column() {
      GridRow({
        columns: 5,
        gutter: { x: 5, y: 10 },
        breakpoints: { value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize },
        direction: GridRowDirection.Row
      }) {
        ForEach(this.bgColors, (color: Color) => {
          GridCol({ span: { xs: 1, sm: 2, md: 3, lg: 4 }, offset: 0, order: 0 }) {
            Row().width("100%").height("20vp")
          }.borderColor(color).borderWidth(2)
        })
      }.width("100%").height("100%")
      .onBreakpointChange((breakpoint) => {
        this.currentBp = breakpoint
      })
    }.width('80%').margin({ left: 10, top: 5, bottom: 5 }).height(200)
    .border({ color: '#880606', width: 2 })
  }
}
```

![figures/gridrow.png](figures/gridrow.png)
```

--------------------------------

TITLE: Initialize XComponentController
DESCRIPTION: Demonstrates the basic instantiation of the XComponentController class. This is the starting point for interacting with XComponent functionalities.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-xcomponent.md#_snippet_18

LANGUAGE: typescript
CODE:
```
xcomponentController: XComponentController = new XComponentController();
```

--------------------------------

TITLE: Set Start and End Dates for CalendarPicker (ArkTS)
DESCRIPTION: This example shows how to set the start and end dates for the CalendarPicker dialog using the start and end properties of CalendarOptions. This limits the selectable date range within the dialog.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-methods-calendarpicker-dialog.md#_snippet_4

LANGUAGE: ArkTS
CODE:
```
// xxx.ets
@Entry
@Component
struct CalendarPickerDialogExample {
  private selectedDate: Date = new Date('2025-01-01');
  private startDate: Date = new Date('2024-01-10');
  private endDate: Date = new Date('2025-1-10');

  build() {
    Column() {
      Text('月历日期选择器').fontSize(30)
      Button("Show CalendarPicker Dialog")
        .margin(20)
        .onClick(() => {
          console.info("CalendarDialog.show");
          CalendarPickerDialog.show({
            start: this.startDate,
            end: this.endDate,
            selected: this.selectedDate,
          });
        })
    }.width('100%').margin({ top: 350 })
  }
}
```

--------------------------------

TITLE: InnerFullScreenLaunchComponent Example
DESCRIPTION: Demonstrates the usage of InnerFullScreenLaunchComponent with a LaunchController to launch atomic services. It includes sample buttons to trigger launching different services by their application IDs.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-InnerFullScreenLaunchComponent-sys.md#_snippet_1

LANGUAGE: typescript
CODE:
```
import { InnerFullScreenLaunchComponent, LaunchController } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  @Builder
  ColumChild() {
    Column() {
      Text('InnerFullScreenLaunchComponent').fontSize(16).margin({top: 100})
      Button('start 日出日落')
        .onClick(()=>{
          let appId1: string = '576****************';
          this.controller.launchAtomicService(appId1, {});
        }).height(30).width('50%').margin({top: 50})
      Button('start 充值')
        .onClick(()=>{
          let appId2: string = '576****************';
          this.controller.launchAtomicService(appId2, {});
        }).height(30).width('50%').margin({top: 50})
    }.backgroundColor(Color.Pink).height('100%').width('100%')
  }
  controller: LaunchController = new LaunchController();

  build() {
    Column() {
      InnerFullScreenLaunchComponent({
          content: this.ColumChild,
          controller: this.controller,
          onReceive: (data) => {
            console.info("onReceive, data: " + data['ohos.atomicService.window']);
          }
        })
    }
    .width('100%').height('100%')
  }
}
```

--------------------------------

TITLE: ArkTS LoadingDialog Example
DESCRIPTION: Demonstrates a loading indicator dialog using LoadingDialog from @kit.ArkUI. It displays a message while loading and can be presented to the user.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Dialog.md#_snippet_24

LANGUAGE: typescript
CODE:
```
import { LoadingDialog } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  dialogControllerProgress: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: '文本文本文本文本文本...',
    }),
  })

  build() {
    Row() {
      Stack() {
        Column() {
          Button("进度加载类弹出框")
            .width(96)
            .height(40)
            .onClick(() => {
              this.dialogControllerProgress.open()
            })
        }
        .margin({ bottom: 300 })
      }
      .align(Alignment.Bottom)
      .width('100%')
      .height('100%')
    }
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
  }
}
```

--------------------------------

TITLE: Example: Styling a Popup with Options
DESCRIPTION: Demonstrates how to customize a popup's appearance by configuring PopupIconOptions, PopupTextOptions, and PopupButtonOptions. This example showcases setting an icon, title, message, and multiple buttons with specific styles.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Popup.md#_snippet_7

LANGUAGE: ts
CODE:
```
// xxx.ets
import { Popup, PopupTextOptions, PopupButtonOptions, PopupIconOptions } from '@kit.ArkUI';

@Entry
@Component
struct PopupExample {
  build() {
    Row() {
      // popup 自定义高级组件
      Popup({
        // PopupIconOptions类型设置图标内容
        icon: {
          // $r('app.media.icon')需要替换为开发者所需的图像资源文件。
          image: $r('app.media.icon'),
          width: 32,
          height: 32,
          fillColor: Color.White,
          borderRadius: 16
        } as PopupIconOptions,
        // PopupTextOptions类型设置文字内容
        title: {
          text: 'This is a popup with PopupOptions',
          fontSize: 20,
          fontColor: Color.Black,
          fontWeight: FontWeight.Normal
        } as PopupTextOptions,
        // PopupTextOptions类型设置文字内容
        message: {
          text: 'This is the message',
          fontSize: 15,
          fontColor: Color.Black
        } as PopupTextOptions,
        showClose: false,
        onClose: () => {
          console.info('close Button click');
        },
        // PopupButtonOptions类型设置按钮内容
        buttons: [{
          text: 'confirm',
          action: () => {
            console.info('confirm button click');
          },
          fontSize: 15,
          fontColor: Color.Black,
        },
          {
            text: 'cancel',
            action: () => {
              console.info('cancel button click');
            },
            fontSize: 15,
            fontColor: Color.Black
          },] as [PopupButtonOptions?, PopupButtonOptions?]
      })
    }
    .width(300)
    .height(200)
    .borderWidth(2)
    .justifyContent(FlexAlign.Center)
  }
}
```

--------------------------------

TITLE: VideoController start
DESCRIPTION: Starts or resumes video playback.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-media-components-video.md#_snippet_49

LANGUAGE: APIDOC
CODE:
```
## VideoController start

### Description
Starts or resumes video playback.

### Method
start

### Endpoint
N/A (Method of VideoController)

### Parameters
None

### Request Example
```ts
controller.start();
```

### Response
None
```

--------------------------------

TITLE: NodeContainer Example
DESCRIPTION: Demonstrates how to mount a BuilderNode using a NodeController. This example showcases the usage of NodeContainer for dynamic UI element management.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-nodecontainer.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
## NodeContainer Usage Example

### Description
This example demonstrates mounting a `BuilderNode` within a `NodeContainer` using a custom `NodeController`.

### Method
Component Declaration and Instantiation

### Endpoint
N/A (Component usage within ArkUI)

### Parameters
None (Component properties and events are configured separately)

### Request Example
```typescript
import { NodeController, BuilderNode, FrameNode, UIContext } from '@kit.ArkUI';

// Define parameters for the builder
declare class Params {
  text: string
}

// Define the builder function
@Builder
function buttonBuilder(params: Params) {
  Flex({
    direction: FlexDirection.Column,
    alignItems: ItemAlign.Center,
    justifyContent: FlexAlign.SpaceEvenly
  }) {
    Text(params.text)
      .fontSize(12)
    Button(`This is a Button`, {
      type: ButtonType.Normal,
      stateEffect: true
    })
      .fontSize(12)
      .borderRadius(8)
      .backgroundColor(0x317aff)
  }
  .height(100)
  .width(200)
}

// Custom NodeController implementation
class MyNodeController extends NodeController {
  private rootNode: BuilderNode<[Params]> | null = null;
  private wrapBuilder: WrappedBuilder<[Params]> = wrapBuilder(buttonBuilder);

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootNode === null) {
      this.rootNode = new BuilderNode(uiContext);
      this.rootNode.build(this.wrapBuilder, { text: "This is a Text" })
    }
    return this.rootNode.getFrameNode();
  }
}

// Main component using NodeContainer
@Entry
@Component
struct Index {
  private baseNode: MyNodeController = new MyNodeController()

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Start,
      justifyContent: FlexAlign.SpaceEvenly
    }) {
      Text("This is a NodeContainer contains a text and a button ")
        .fontSize(9)
        .fontColor(0xCCCCCC)
      NodeContainer(this.baseNode)
        .borderWidth(1)
        .onClick(() => {
          console.log("click event");
        })
    }
    .padding({ left: 35, right: 35, top: 35 })
    .height(200)
    .width(300)
  }
}
```

### Response
None (UI rendering is handled by the ArkUI framework)
```

--------------------------------

TITLE: Example 2: CalendarPicker with Start and End Dates
DESCRIPTION: Illustrates how to configure the CalendarPicker to restrict date selection within a specified start and end date range.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-calendarpicker.md#_snippet_17

LANGUAGE: APIDOC
CODE:
```
## Example: CalendarPicker with Date Range

### Description
This example shows how to set the start and end dates for the CalendarPicker component using the `start` and `end` properties.

### Code

```ts
// xxx.ets
@Entry
@Component
struct CalendarPickerExample {
  private selectedDate: Date = new Date('2025-01-15');
  private startDate: Date = new Date('2025-01-05');
  private endDate: Date = new Date('2025-01-25');

  build() {
    Column() {
      Column() {
        CalendarPicker({
          hintRadius: 10,
          selected: this.selectedDate,
          start: this.startDate,
          end: this.endDate
        })
          .edgeAlign(CalendarAlign.END)
          .textStyle({ color: "#ff182431", font: { size: 20, weight: FontWeight.Normal } })
          .margin(10)
          .onChange((value) => {
            console.info(`CalendarPicker onChange: ${value.toString()}`);
          })
      }.alignItems(HorizontalAlign.End).width("100%")
    }.width('100%').margin({ top: 350 })
  }
}
```
```

--------------------------------

TITLE: Set TimePickerDialog Start Time in ArkTS
DESCRIPTION: This example demonstrates how to set the start time for the TimePickerDialog using the 'start' property. It configures the dialog to allow users to select time from a specified start time onwards.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-methods-timepicker-dialog.md#_snippet_9

LANGUAGE: typescript
CODE:
```
import { TimePickerResult, TimePickerFormat } from '@ohos.timepicker';

// xxx.ets
@Entry
@Component
struct TimePickerDialogExample {
  private selectTime: Date = new Date('2022-07-22T08:50:00');

  build() {
    Column() {
      Button("TimePickerDialog")
        .margin(20)
        .onClick(() => {
          this.getUIContext().showTimePickerDialog({
            useMilitaryTime: false,
            selected: this.selectTime,
            format: TimePickerFormat.HOUR_MINUTE_SECOND,
            start: new Date('2022-07-22T08:30:00'),
            onAccept: (value: TimePickerResult) => {
              // Set selectTime to the time selected when the confirm button is pressed,
              // so that the dialog displays the previously confirmed time when it pops up again.
              if (value.hour != undefined && value.minute != undefined) {
                this.selectTime.setHours(value.hour, value.minute);
                console.info("TimePickerDialog:onAccept()" + JSON.stringify(value));
              }
            }
          });
        })
    }.width('100%')
  }
}
```

--------------------------------

TITLE: Line Component Examples
DESCRIPTION: Provides examples of how to use the Line component with various properties like startPoint, endPoint, stroke, strokeWidth, strokeDashArray, strokeLineCap, and fillOpacity.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-drawing-components-line.md#_snippet_21

LANGUAGE: APIDOC
CODE:
```
## Line Component Examples

### Example 1: Component Property Drawing
Demonstrates drawing lines using `startPoint`, `endPoint`, `fillOpacity`, `stroke`, `strokeDashArray`, and `strokeDashOffset`.

```typescript
// xxx.ets
@Entry
@Component
struct LineExample {
  build() {
    Column({ space: 10 }) {
      // Line drawing start and end points are relative to the Line component's drawing area
      Line()
        .width(200)
        .height(150)
        .startPoint([0, 0])
        .endPoint([50, 100])
        .stroke(Color.Black)
        .backgroundColor('#F5F5F5')
      Line()
        .width(200)
        .height(150)
        .startPoint([50, 50])
        .endPoint([150, 150])
        .strokeWidth(5)
        .stroke(Color.Orange)
        .strokeOpacity(0.5)
        .backgroundColor('#F5F5F5')
      // strokeDashOffset is used to define the offset when rendering the dashed line array
      Line()
        .width(200)
        .height(150)
        .startPoint([0, 0])
        .endPoint([100, 100])
        .stroke(Color.Black)
        .strokeWidth(3)
        .strokeDashArray([10, 3])
        .strokeDashOffset(5)
        .backgroundColor('#F5F5F5')
      // When the coordinate point values exceed the Line component's width and height, the line will be drawn outside the component's drawing area
      Line()
        .width(50)
        .height(50)
        .startPoint([0, 0])
        .endPoint([100, 100])
        .stroke(Color.Black)
        .strokeWidth(3)
        .strokeDashArray([10, 3])
        .backgroundColor('#F5F5F5')
    }
  }
}
```

![Example Image 1](figures/zh-cn_image_0000001219982725.png)

### Example 2: Border End Cap Drawing
Demonstrates drawing the border end cap style of lines using the `strokeLineCap` property.

```typescript
// xxx.ets
@Entry
@Component
struct LineExample1 {
  build() {
    Row({ space: 10 }) {
      // When LineCapStyle is Butt
      Line()
        .width(100)
        .height(200)
        .startPoint([50, 50])
        .endPoint([50, 200])
        .stroke(Color.Black)
        .strokeWidth(20)
        .strokeLineCap(LineCapStyle.Butt)
        .backgroundColor('#F5F5F5')
        .margin(10)
      // When LineCapStyle is Round
      Line()
        .width(100)
        .height(200)
        .startPoint([50, 50])
        .endPoint([50, 200])
        .stroke(Color.Black)
        .strokeWidth(20)
        .strokeLineCap(LineCapStyle.Round)
        .backgroundColor('#F5F5F5')
      // When LineCapStyle is Square
      Line()
        .width(100)
        .height(200)
        .startPoint([50, 50])
        .endPoint([50, 200])
        .stroke(Color.Black)
        .strokeWidth(20)
        .strokeLineCap(LineCapStyle.Square)
        .backgroundColor('#F5F5F5')
    }
  }
}
```

![Example Image 2](figures/zh-cn_image1_0000001219982725.png)

### Example 3: Border Gap Drawing
Demonstrates drawing the border gap style of lines using the `strokeDashArray` property.

```typescript
// xxx.ets
@Entry
@Component
struct LineExample {
  build() {
    Column() {
      Line()
        .width(300)
        .height(30)
        .startPoint([50, 30])
        .endPoint([300, 30])
        .stroke(Color.Black)
        .strokeWidth(10)
      // Set strokeDashArray interval to 50
      Line()
        .width(300)
        .height(30)
        .startPoint([50, 20])
        .endPoint([300, 20])
        .stroke(Color.Black)
        .strokeWidth(10)
        .strokeDashArray([50])
      // Set strokeDashArray intervals to 50, 10
      Line()
        .width(300)
        .height(30)
        .startPoint([50, 20])
        .endPoint([300, 20])
        .stroke(Color.Black)
        .strokeWidth(10)
        .strokeDashArray([50, 10])
      // Set strokeDashArray intervals to 50, 10, 20
      Line()
        .width(300)
        .height(30)
        .startPoint([50, 20])
        .endPoint([300, 20])
        .stroke(Color.Black)
        .strokeWidth(10)
        .strokeDashArray([50, 10, 20])
      // Set strokeDashArray intervals to 50, 10, 20, 30
      Line()
        .width(300)
        .height(30)
        .startPoint([50, 20])
        .endPoint([300, 20])
        .stroke(Color.Black)
        .strokeWidth(10)
        .strokeDashArray([50, 10, 20, 30])
    }
  }
}
```

![Example Image 3](figures/zh-cn_image2_0000001219982725.PNG)

```

--------------------------------

TITLE: Initiate Navigation (ArkTS)
DESCRIPTION: This snippet demonstrates the initial navigation setup in ArkTS, where a 'NavIndex' page is created, and a button click triggers navigation to another page named 'pageOne' using `pushPath`.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-navigation.md#_snippet_123

LANGUAGE: typescript
CODE:
```
// Index.ets
@Entry
@Component
struct NavigationExample {
  pageInfo: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageInfo) {
      Column() {
        Button('StartTest', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin(20)
          .onClick(() => {
            this.pageInfo.pushPath({ name: 'pageOne' }); // 将name指定的NavDestination页面信息入栈。
          })
      }
    }.title('NavIndex')
  }
}
```

--------------------------------

TITLE: Example TextTimer with controls
DESCRIPTION: Demonstrates the basic usage of the TextTimer component with manual start, pause, and reset controls. The timer is configured for countdown and displays time in 'mm:ss.SS' format.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-texttimer.md#_snippet_9

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct TextTimerExample {
  textTimerController: TextTimerController = new TextTimerController();
  @State format: string = 'mm:ss.SS';

  build() {
    Column() {
      TextTimer({ isCountDown: true, count: 30000, controller: this.textTimerController })
        .format(this.format)
        .fontColor(Color.Black)
        .fontSize(50)
        .onTimer((utc: number, elapsedTime: number) => {
          console.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
        })
      Row() {
        Button("start").onClick(() => {
          this.textTimerController.start();
        })
        Button("pause").onClick(() => {
          this.textTimerController.pause();
        })
        Button("reset").onClick(() => {
          this.textTimerController.reset();
        })
      }
    }
  }
}
```

--------------------------------

TITLE: Stack Component Example
DESCRIPTION: A practical example demonstrating the usage of the Stack component with `alignContent` set to `Alignment.Bottom`.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-stack.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
## Stack Component Example

### Description
This example showcases the Stack component with its `alignContent` property configured to `Alignment.Bottom`, illustrating how child components are positioned.

### Code
```typescript
// xxx.ets
@Entry
@Component
struct StackExample {
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('First child, show in bottom').width('90%').height('100%').backgroundColor(0xd2cab3).align(Alignment.Top)
      Text('Second child, show in top').width('70%').height('60%').backgroundColor(0xc1cbac).align(Alignment.Top)
    }.width('100%').height(150).margin({ top: 5 })
  }
}
```

### Visual Output
![Stack Example Output](figures/zh-cn_image_0000001219982699.PNG)
```

--------------------------------

TITLE: Navigator Example Usage
DESCRIPTION: Demonstrates how to use the Navigator component for page navigation, including passing parameters and handling back navigation.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-navigator.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
### Navigator Example

```ts
// Navigator.ets
@Entry
@Component
struct NavigatorExample {
  @State active: boolean = false
  @State name: NameObject = { name: 'news' }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      Navigator({ target: 'pages/container/navigator/Detail', type: NavigationType.Push }) {
        Text('Go to ' + this.name.name + ' page')
          .width('100%').textAlign(TextAlign.Center)
      }.params(new TextObject(this.name)) // Pass parameters to the Detail page

      Navigator() {
        Text('Back to previous page').width('100%').textAlign(TextAlign.Center)
      }
      .active(this.active)
      .onClick(() => {
        this.active = true
      })
    }.height(150).width(350).padding(35)
  }
}

interface NameObject {
  name: string;
}

class TextObject {
  text: NameObject;

  constructor(text: NameObject) {
    this.text = text;
  }
}
```

```ts
// Detail.ets
@Entry
@Component
struct DetailExample {
  // Receive parameters from Navigator.ets
  params: Record<string, NameObject> = this.getUIContext().getRouter().getParams() as Record<string, NameObject>
  @State name: NameObject = this.params.text

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      Navigator({ target: 'pages/container/navigator/Back', type: NavigationType.Push }) {
        Text('Go to back page').width('100%').height(20)
      }

      Text('This is ' + this.name.name + ' page')
        .width('100%').textAlign(TextAlign.Center)
    }
    .width('100%').height(200).padding({ left: 35, right: 35, top: 35 })
  }
}

interface NameObject {
  name: string;
}
```

```ts
// Back.ets
@Entry
@Component
struct BackExample {
  build() {
    Column() {
      Navigator({ target: 'pages/container/navigator/Navigator', type: NavigationType.Back }) {
        Text('Return to Navigator Page').width('100%').textAlign(TextAlign.Center)
      }
    }.width('100%').height(200).padding({ left: 35, right: 35, top: 35 })
  }
}
```

![zh-cn_image_0000001219864145](figures/zh-cn_image_0000001219864145.gif)
```

--------------------------------

TITLE: Example 1: Setting GridItem Position
DESCRIPTION: Demonstrates how to set the position of a GridItem using ColumnStart, ColumnEnd, RowStart, and RowEnd attributes. It's recommended to use the layoutOptions parameter of the Grid for scenarios requiring specific start and end row/column numbers. Refer to Grid's Example 1 (Fixed Row/Column Grid) and Example 3 (Scrollable Grid with Spanning Nodes) for more details.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-griditem.md#_snippet_17

LANGUAGE: APIDOC
CODE:
```
## Example 1: Setting GridItem Position

### Description
GridItem sets its own position through reasonable ColumnStart, ColumnEnd, RowStart, RowEnd attributes. For scenarios that require specifying the start and end row and column numbers of GridItem, it is recommended to use the `layoutOptions` parameter of Grid. For details, refer to [Grid's Example 1](ts-container-grid.md#示例1固定行列grid) and [Grid's Example 3](ts-container-grid.md#示例3可滚动grid设置跨行跨列节点).

### Code
```ts
// xxx.ets
@Entry
@Component
struct GridItemExample {
  @State numbers: string[] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];

  build() {
    Column() {
      Grid() {
        GridItem() {
          Text('4')
            .fontSize(16)
            .backgroundColor(0xFAEEE0)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Center)
        }.rowStart(1).rowEnd(2).columnStart(1).columnEnd(2) // Simultaneously set reasonable row and column numbers

        ForEach(this.numbers, (item: string) => {
          GridItem() {
            Text(item)
              .fontSize(16)
              .backgroundColor(0xF9CF93)
              .width('100%')
              .height('100%')
              .textAlign(TextAlign.Center)
          }
        }, (item: string) => item)

        GridItem() {
          Text('5')
            .fontSize(16)
            .backgroundColor(0xDBD0C0)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Center)
        }.columnStart(1).columnEnd(4) // Only set column number, will not start layout from the first column
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
      .width('90%').height(300)
    }.width('100%').margin({ top: 5 })
  }
}
```

### Image
![zh-cn_image_0000001174582870](figures/zh-cn_image_0000001174582870.gif)
```

--------------------------------

TITLE: Example: Popup Styling
DESCRIPTION: Demonstrates how to style a popup using PopupIconOptions, PopupTextOptions, and PopupButtonOptions.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Popup.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
## Example 1 (Setting Popup Style)

This example configures PopupIconOptions, PopupTextOptions, and PopupButtonOptions to achieve the popup style.

```ts
// xxx.ets
import { Popup, PopupTextOptions, PopupButtonOptions, PopupIconOptions } from '@kit.ArkUI';

@Entry
@Component
struct PopupExample {
  build() {
    Row() {
      // Popup custom advanced component
      Popup({
        // PopupIconOptions type sets icon content
        icon: {
          // $r('app.media.icon') needs to be replaced with the developer's required image resource file.
          image: $r('app.media.icon'),
          width: 32,
          height: 32,
          fillColor: Color.White,
          borderRadius: 16
        } as PopupIconOptions,
        // PopupTextOptions type sets text content
        title: {
          text: 'This is a popup with PopupOptions',
          fontSize: 20,
          fontColor: Color.Black,
          fontWeight: FontWeight.Normal
        } as PopupTextOptions,
        // PopupTextOptions type sets text content
        message: {
          text: 'This is the message',
          fontSize: 15,
          fontColor: Color.Black
        } as PopupTextOptions,
        showClose: false,
        onClose: () => {
          console.info('close Button click');
        },
        // PopupButtonOptions type sets button content
        buttons: [{
          text: 'confirm',
          action: () => {
            console.info('confirm button click');
          },
          fontSize: 15,
          fontColor: Color.Black,
        },
          {
            text: 'cancel',
            action: () => {
              console.info('cancel button click');
            },
            fontSize: 15,
            fontColor: Color.Black
          },] as [PopupButtonOptions?, PopupButtonOptions?]
      })
    }
    .width(300)
    .height(200)
    .borderWidth(2)
    .justifyContent(FlexAlign.Center)
  }
}
```

![](figures/popup_7.png)
```

--------------------------------

TITLE: Customize Background Effect (ArkTS, API 19+)
DESCRIPTION: Starting from API version 19, this example demonstrates how to customize the overall background effect of the CalendarPicker dialog using the `backgroundEffect` property. This includes adjusting radius, saturation, brightness, and color.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-methods-calendarpicker-dialog.md#_snippet_7

LANGUAGE: ArkTS
CODE:
```
@Entry
@Component
struct CalendarPickerDialogExample {
  private selectedDate: Date = new Date('2025-08-05');

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.bg'))
      Column() {
        Button("Show CalendarPicker Dialog")
          .margin(20)
          .onClick(() => {
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              hintRadius: 1,
              backgroundColor: undefined,
              backgroundBlurStyle: BlurStyle.Thin,
              backgroundEffect: {
                radius: 60,
                saturation: 0,
                brightness: 1,
                color: Color.White,
                blurOptions: { grayscale: [20, 20] }
              },
            });
          })
      }.width('100%')
    }
  }
}
```

--------------------------------

TITLE: Dynamically Set Canvas Attributes and Methods with attributeModifier
DESCRIPTION: This example shows how to dynamically set Canvas component properties like enableAnalyzer and the onReady method using attributeModifier. It includes functions to start, stop, and get image analyzer support types, utilizing ImageBitmap for drawing and various AI analysis configurations.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-components-canvas-canvas.md#_snippet_7

LANGUAGE: typescript
CODE:
```
// xxx.ets
import { BusinessError } from '@kit.BasicServicesKit';

class MyCanvasModifier implements AttributeModifier<CanvasAttribute> {
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D()

  applyNormalAttribute(instance: CanvasAttribute): void {
    // 从（0，0）绘制一张宽高为200vp的图片
    instance.onReady(() => {
      let image = new ImageBitmap("image.png")
      this.context.drawImage(image, 0, 0, 200, 200)
    })
    // 设置开启组件AI分析功能，点击start后，长按触发AI识别功能
    instance.enableAnalyzer(true)
  }
}

@Entry
@Component
struct attributeDemo {
  @State modifier: MyCanvasModifier = new MyCanvasModifier()
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private config: ImageAnalyzerConfig = {
    types: [ImageAnalyzerType.SUBJECT, ImageAnalyzerType.TEXT]
  }
  private aiController: ImageAnalyzerController = new ImageAnalyzerController()
  private options: ImageAIOptions = {
    types: [ImageAnalyzerType.SUBJECT, ImageAnalyzerType.TEXT],
    aiController: this.aiController
  }

  build() {
    Row() {
      Column() {
        Button('start')
          .width(100)
          .height(50)
          .margin(5)
          .onClick(() => {
            this.context.startImageAnalyzer(this.config)
              .then(() => {
                console.log("analysis complete")
              })
              .catch((error: BusinessError) => {
                console.log("error code: " + error.code)
              })
          })
        Button('stop')
          .width(100)
          .height(50)
          .margin(5)
          .onClick(() => {
            this.context.stopImageAnalyzer()
          })
        Button('getTypes')
          .width(100)
          .height(50)
          .margin(5)
          .onClick(() => {
            this.aiController.getImageAnalyzerSupportTypes()
          })
        Canvas(this.context, this.options)
          .borderWidth(1)
          .height(200)
          .width(200)
          .attributeModifier(this.modifier)
          .onAppear(() => {
            this.modifier.context = this.context
          })
      }
    }
  }
}
```

--------------------------------

TITLE: Customize Background Blur Style (ArkTS, API 19+)
DESCRIPTION: Starting from API version 19, this example shows how to customize the background blur effect of the CalendarPicker dialog using `backgroundBlurStyleOptions`. It allows fine-tuning of blur parameters like color mode and scale.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-methods-calendarpicker-dialog.md#_snippet_6

LANGUAGE: ArkTS
CODE:
```
@Entry
@Component
struct CalendarPickerDialogExample {
  private selectedDate: Date = new Date('2025-08-05');

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.bg'))
      Column() {
        Button("Show CalendarPicker Dialog")
          .margin(20)
          .onClick(() => {
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              hintRadius: 1,
              backgroundColor: undefined,
              backgroundBlurStyle: BlurStyle.Thin,
              backgroundBlurStyleOptions: {
                colorMode: ThemeColorMode.LIGHT,
                adaptiveColor: AdaptiveColor.AVERAGE,
                scale: 1,
                blurOptions: { grayscale: [20, 20] },
              },
            });
          })
      }.width('100%')
    }
  }
}
```

--------------------------------

TITLE: ArkTS EntryAbility Setup
DESCRIPTION: Sets up the main window for the ArkTS application, loads the initial content, and retrieves the UI context for dialogs. It handles window creation and lifecycle events.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-atomicservice-InterstitialDialogAction.md#_snippet_12

LANGUAGE: typescript
CODE:
```
// ../entryability/EntryAbility
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

let dialogUIContext: UIContext | null = null;

export function getDialogUIContext(): UIContext | null {
  return dialogUIContext;
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((err: BusinessError, data) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass = data;
      console.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));
      dialogUIContext = windowClass.getUIContext();
    })

    //获取窗口
    windowStage.getMainWindow((err, data) => {
      if (err.code) {
        console.error('Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass = data;
      console.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));
      //设置窗口全屏
      windowClass.setWindowLayoutFullScreen(false)
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
```

--------------------------------

TITLE: ArkTS LoadingDialogV2 Example
DESCRIPTION: Implements a loading dialog that displays a progress indicator along with custom text content. This example uses the LoadingDialogV2 component from ArkUI.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-DialogV2.md#_snippet_25

LANGUAGE: typescript
CODE:
```
import { LoadingDialogV2, UIContext  } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
  @Builder
  dialogBuilder(): void {
    LoadingDialogV2({
      content: '文本文本文本文本文本...',
    })
  }

  build() {
    Row() {
      Stack() {
        Column() {
          Button("打开LoadingDialogV2弹出框")
            .width(96)
            .height(40)
            .onClick(() => {
              let uiContext: UIContext = this.getUIContext();
              uiContext.getPromptAction().openCustomDialog({
                builder: () => {
                  this.dialogBuilder();
                }
              });
            })
        }.margin({ bottom: 300 })
      }.align(Alignment.Bottom)
      .width('100%').height('100%')
    }
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
  }
}
```

--------------------------------

TITLE: Configure Wearable Device Type in module.json5
DESCRIPTION: This JSON snippet shows how to configure the project to support 'wearable' devices by adding it to the deviceTypes array in the module.json5 file. This is a prerequisite for running the ArcButton example on wearable devices.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-ArcButton.md#_snippet_0

LANGUAGE: json
CODE:
```
// module.json5
{
  "module": {
    // ...
    "deviceTypes": [
      "wearable",
      "phone"
    ]
    // ...
  }
}
```

--------------------------------

TITLE: Configure Background Properties with Examples (ArkTS)
DESCRIPTION: Demonstrates setting various background properties for components, including background color, background images with different repeat modes (X, Y, NoRepeat), background image sizing (Cover, Contain), and background image positioning. This example uses ArkTS and assumes image resources are available via $r('app.media.image').

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-universal-attributes-background.md#_snippet_47

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct BackgroundExample {

  build() {
    Column({ space: 5 }) {
      Text('background color').fontSize(9).width('90%').fontColor(0xCCCCCC)
      Row().width('90%').height(50).backgroundColor(0xE5E5E5).border({ width: 1 })

      Text('background image repeat along X').fontSize(9).width('90%').fontColor(0xCCCCCC)
      Row()
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.X)
        .backgroundImageSize({ width: '250px', height: '140px' })
        .width('90%')
        .height(70)
        .border({ width: 1 })

      Text('background image repeat along Y').fontSize(9).width('90%').fontColor(0xCCCCCC)
      Row()
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.Y)
        .backgroundImageSize({ width: '500px', height: '120px' })
        .width('90%')
        .height(100)
        .border({ width: 1 })

      Text('background image size').fontSize(9).width('90%').fontColor(0xCCCCCC)
      Row()
        .width('90%').height(150)
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.NoRepeat)
        .backgroundImageSize({ width: 1000, height: 500 })
        .border({ width: 1 })

      Text('background fill the box(Cover)').fontSize(9).width('90%').fontColor(0xCCCCCC)
      // 不保证图片完整的情况下占满盒子
      Row()
        .width(200)
        .height(50)
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.NoRepeat)
        .backgroundImageSize(ImageSize.Cover)
        .border({ width: 1 })

      Text('background fill the box(Contain)').fontSize(9).width('90%').fontColor(0xCCCCCC)
      // 保证图片完整的情况下放到最大
      Row()
        .width(200)
        .height(50)
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.NoRepeat)
        .backgroundImageSize(ImageSize.Contain)
        .border({ width: 1 })

      Text('background image position').fontSize(9).width('90%').fontColor(0xCCCCCC)
      Row()
        .width(100)
        .height(50)
        //$r('app.media.image')需要替换为开发者所需的图像资源文件。
        .backgroundImage($r('app.media.image'), ImageRepeat.NoRepeat)
        .backgroundImageSize({ width: 1000, height: 560 })
        .backgroundImagePosition({ x: -500, y: -300 })
        .border({ width: 1 })
    }
    .width('100%').height('100%').padding({ top: 5 })
  }
}
```

--------------------------------

TITLE: LaunchController
DESCRIPTION: Manages the process of launching atomic services.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-InnerFullScreenLaunchComponent-sys.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
## LaunchController

### Description
Provides methods to control the launching of atomic services.

### Method
Constructor

### Endpoint
N/A (Class)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Methods
*   **launchAtomicService** ([LaunchAtomicServiceCallback](#launchatomicservicecallback))
    *   **Description**: Initiates the launch of an atomic service.
    *   **Parameters**:
        *   `appId` (string) - Required - The application ID of the atomic service.
        *   `options` ([AtomicServiceOptions](../../apis-ability-kit/js-apis-app-ability-atomicServiceOptions.md)) - Optional - Parameters for launching the atomic service.

### Request Example
```typescript
let appId: string = 'your_app_id';
controller.launchAtomicService(appId, {});
```

### Response
#### Success Response (N/A)

#### Response Example
(No direct response for method call)

```

--------------------------------

TITLE: Drawing Example
DESCRIPTION: Example demonstrating how to use DrawingRenderingContext methods for drawing on a Canvas.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-drawingrenderingcontext.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
## Drawing Example

### Description
This example demonstrates how to use methods within DrawingRenderingContext for drawing.

### Code
```ts
import { common2D, drawing } from '@kit.ArkGraphics2D';

// xxx.ets
@Entry
@Component
struct CanvasExample {
  private context: DrawingRenderingContext = new DrawingRenderingContext();

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Canvas(this.context)
        .width('100%')
        .height('50%')
        .backgroundColor('#D5D5D5')
        .onReady(() => {
          let brush = new drawing.Brush();
          // Use RGBA(39, 135, 217, 255) to fill a circle with center (200, 200) and radius 100
          brush.setColor({
            alpha: 255,
            red: 39,
            green: 135,
            blue: 217
          });
          this.context.canvas.attachBrush(brush);
          this.context.canvas.drawCircle(200, 200, 100);
          this.context.canvas.detachBrush();
          this.context.invalidate();
        })
      Button("Clear")
        .width('120')
        .height('50')
        .onClick(() => {
          let color: common2D.Color = {
            alpha: 0,
            red: 0,
            green: 0,
            blue: 0
          };
          // Fill the canvas with RGBA(0, 0, 0, 0)
          this.context.canvas.clear(color);
          this.context.invalidate();
        })
    }
    .width('100%')
    .height('100%')
  }
}
```

### Visual Output
- Figure 1: Draws a circle with center (200, 200) and radius 100, filled with RGBA(39, 135, 217, 255).
- Figure 2: Clears the canvas upon clicking the Clear button.
```

--------------------------------

TITLE: ArkTS SelectDialog Example
DESCRIPTION: Demonstrates a list-based dialog with selectable radio options using SelectDialog from @kit.ArkUI. It manages the selected index and provides actions for each list item.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Dialog.md#_snippet_21

LANGUAGE: typescript
CODE:
```
import { SelectDialog } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  // 设置默认选中radio的index
  radioIndex = 0;
  dialogControllerList: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: '文本标题',
      selectedIndex: this.radioIndex,
      confirm: {
        value: '取消',
        action: () => {}, 
      },
      radioContent: [
        {
          title: '文本文本文本文本文本',
          action: () => {
            this.radioIndex = 0
          }
        },
        {
          title: '文本文本文本文本',
          action: () => {
            this.radioIndex = 1
          }
        },
        {
          title: '文本文本文本文本',
          action: () => {
            this.radioIndex = 2
          }
        },
      ]
    }),
  })

  build() {
    Row() {
      Stack() {
        Column() {
          Button("纯列表弹出框")
            .width(96)
            .height(40)
            .onClick(() => {
              this.dialogControllerList.open()
            })
        }.margin({ bottom: 300 })
      }
      .align(Alignment.Bottom)
      .width('100%')
      .height('100%')
    }
    .backgroundImageSize({ width: '100%', height: '100%' })
    .height('100%')
  }
}
```

--------------------------------

TITLE: Draw Lines with Various Properties
DESCRIPTION: Demonstrates drawing lines with specified start and end points, stroke color, width, opacity, and dash patterns. Includes examples for setting strokeDashArray and strokeDashOffset.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-drawing-components-line.md#_snippet_16

LANGUAGE: typescript
CODE:
```

      // xxx.ets
      @Entry
      @Component
      struct LineExample {
        build() {
          Column({ space: 10 }) {
            // 线条绘制的起止点坐标均是相对于Line组件本身绘制区域的坐标
            Line()
              .width(200)
              .height(150)
              .startPoint([0, 0])
              .endPoint([50, 100])
              .stroke(Color.Black)
              .backgroundColor('#F5F5F5')
            Line()
              .width(200)
              .height(150)
              .startPoint([50, 50])
              .endPoint([150, 150])
              .strokeWidth(5)
              .stroke(Color.Orange)
              .strokeOpacity(0.5)
              .backgroundColor('#F5F5F5')
            // strokeDashOffset用于定义关联虚线strokeDashArray数组渲染时的偏移
            Line()
              .width(200)
              .height(150)
              .startPoint([0, 0])
              .endPoint([100, 100])
              .stroke(Color.Black)
              .strokeWidth(3)
              .strokeDashArray([10, 3])
              .strokeDashOffset(5)
              .backgroundColor('#F5F5F5')
            // 当坐标点设置的值超出Line组件的宽高范围时，线条会画出组件绘制区域
            Line()
              .width(50)
              .height(50)
              .startPoint([0, 0])
              .endPoint([100, 100])
              .stroke(Color.Black)
              .strokeWidth(3)
              .strokeDashArray([10, 3])
              .backgroundColor('#F5F5F5')
          }
        }
      }
      
```

--------------------------------

TITLE: Example Usage
DESCRIPTION: Provides an example of how to use geometryTransition in an ArkTS component for shared element transitions, demonstrating dynamic view switching and animation.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-transition-animation-geometrytransition.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
```ts
// xxx.ets
@Entry
@Component
struct Index {
  @State isShow: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isShow) {
        // Image uses Resource resources, requires user customization
        Image($r('app.media.pic'))
          .autoResize(false)
          .clip(true)
          .width(300)
          .height(400)
          .offset({ y: 100 })
          .geometryTransition("picture", { follow: false })
          .transition(TransitionEffect.OPACITY);
      } else {
        // geometryTransition binds to the container here, so child components within the container must be set to relative layout to follow parent container changes.
        // Multiple container layers are used to illustrate the propagation of relative layout constraints.
        Column() {
          Column() {
            // Image uses Resource resources, requires user customization
            Image($r('app.media.icon'))
              .width('100%').height('100%');
          }.width('100%').height('100%');
        }
        .width(80)
        .height(80)
        // geometryTransition synchronizes border radius, but only at the geometryTransition binding point. Here, binding to the container synchronizes the container's border radius and does not affect the borderRadius of child components within the container.
        .borderRadius(20)
        .clip(true)
        .geometryTransition("picture");
        // transition ensures that the component is not immediately destructed upon exit, and other transition effects can be set.
        .transition(TransitionEffect.OPACITY);
      }
    }
    .onClick(() => {
      this.getUIContext().animateTo({ duration: 1000 }, () => {
        this.isShow = !this.isShow;
      });
    });
  }
}
```

![geometrytransition](figures/geometrytransition.gif)
```

--------------------------------

TITLE: GridRow Component Example in ArkTS
DESCRIPTION: A basic usage example of the GridRow component, demonstrating setting columns, gutter, breakpoints, direction, and handling breakpoint changes. This example is suitable for ArkTS development.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-gridrow.md#_snippet_7

LANGUAGE: typescript
CODE:
```
@entry
@component
struct GridRowExample {
  @state bgColors: Color[] = [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown]
  @state currentBp: string = 'unknown'

  build() {
    column() {
      gridrow({ 
        columns: 5,
        gutter: { x: 5, y: 10 },
        breakpoints: { value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize },
        direction: GridRowDirection.Row
      }) {
        ForEach(this.bgColors, (color: Color) => {
          gridcol({ span: { xs: 1, sm: 2, md: 3, lg: 4 }, offset: 0, order: 0 }) {
            row().width("100%").height("20vp")
          }.bordercolor(color).borderwidth(2)
        })
      }.width("100%").height("100%")
      .onbreakpointchange((breakpoint) => {
        this.currentBp = breakpoint
      })
    }.width('80%').margin({ left: 10, top: 5, bottom: 5 }).height(200)
    .border({ color: '#880606', width: 2 })
  }
}
```

--------------------------------

TITLE: ArkTS Navigation Setup for WLAN and Bluetooth
DESCRIPTION: This snippet sets up a navigation structure in ArkTS to handle two distinct sections: WLAN and Bluetooth. It utilizes NavRouter and NavDestination to define the routing logic and a NavDestination component to display content for each section. The example also includes state management to visually indicate when a section is active.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-basic-components-navrouter.md#_snippet_9

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct NavRouterExample {
  @State isActiveWLAN: boolean = false
  @State isActiveBluetooth: boolean = false

  build() {
    Navigation() {
      NavRouter() {
        Row() {
          Row()
            .width(30)
            .height(30)
            .borderRadius(30)
            .margin({ left: 3, right: 10 })
            .backgroundColor(Color.Pink)
          Text(`WLAN`)
            .fontSize(22)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
        }
        .width('90%')
        .height(60)

        NavDestination() {
          Flex({ direction: FlexDirection.Row }) {
            Text('未找到可用WLAN').fontSize(30).padding({ left: 15 })
          }
        }.title("WLAN")
      }
      .margin({ top: 10, bottom: 10 })
      .backgroundColor(this.isActiveWLAN ? '#ccc' : '#fff')
      .borderRadius(20)
      .mode(NavRouteMode.PUSH_WITH_RECREATE)
      .onStateChange((isActivated: boolean) => {
        this.isActiveWLAN = isActivated
      })

      NavRouter() {
        Row() {
          Row()
            .width(30)
            .height(30)
            .borderRadius(30)
            .margin({ left: 3, right: 10 })
            .backgroundColor(Color.Pink)
          Text(`蓝牙`)
            .fontSize(22)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
        }
        .width('90%')
        .height(60)

        NavDestination() {
          Flex({ direction: FlexDirection.Row }) {
            Text('未找到可用蓝牙').fontSize(30).padding({ left: 15 })
          }
        }.title("蓝牙")
      }
      .margin({ top: 10, bottom: 10 })
      .backgroundColor(this.isActiveBluetooth ? '#ccc' : '#fff')
      .borderRadius(20)
      .mode(NavRouteMode.REPLACE)
      .onStateChange((isActivated: boolean) => {
        this.isActiveBluetooth = isActivated
      })
    }
    .height('100%')
    .width('100%')
    .title('设置')
    .backgroundColor("#F2F3F5")
    .titleMode(NavigationTitleMode.Free)
    .mode(NavigationMode.Auto)
  }
}
```

--------------------------------

TITLE: ContentCoverOptions
DESCRIPTION: Options for configuring full-screen modal pages, inheriting from BindOptions.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-universal-attributes-modal-transition.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
## ContentCoverOptions

Inherits from [BindOptions](ts-universal-attributes-sheet-transition.md#bindoptions).

### Description
Options for full-screen modal page content.

**System Capability:** SystemCapability.ArkUI.ArkUI.Full

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **modalTransition** ([ModalTransition](ts-universal-attributes-sheet-transition.md#modaltransition)) - Optional - The system transition mode for the full-screen modal page.
  - Default value: `ModalTransition.DEFAULT`.
  - **Note:** This property is ineffective when `transition` is set simultaneously.
  - **Atomic Service API:** Available in atomic services starting from API version 11.
- **onWillDismiss** (Callback&lt;[DismissContentCoverAction](#dismisscontentcoveraction12类型说明)&gt;) - Optional - Callback function for interactive dismissal of the full-screen modal page.
  - **Note:** When the user performs a back event to dismiss, if this callback is registered, dismissal does not occur immediately. Within the callback, `reason` can be used to determine the type of operation preventing the page from closing, allowing conditional dismissal. Interception within `onWillDismiss` is not allowed.
  - **Atomic Service API:** Available in atomic services starting from API version 12.
- **transition** ([TransitionEffect](ts-transition-animation-component.md#transitioneffect10对象说明)) - Optional - The custom transition mode for the full-screen modal page.
  - **Atomic Service API:** Available in atomic services starting from API version 12.
- **enableSafeArea** (boolean) - Optional - Adapts the full-screen modal to the safe area. `true` adapts the modal to the safe area, restricting content within the safe zone to avoid navigation and status bars. `false` means no adjustments are made, maintaining consistency with previous styles. The default value is `false`.
  - **Atomic Service API:** Available in atomic services starting from API version 20.

### Request Example
```json
{
  "modalTransition": "ModalTransition.GRID",
  "onWillDismiss": "myDismissCallback",
  "transition": {
    "type": "MoveIn",
    "direction": "Bottom"
  },
  "enableSafeArea": true
}
```

### Response
#### Success Response (200)
None

#### Response Example
None
```

--------------------------------

TITLE: Get Styles from Styled String Range (ArkTS)
DESCRIPTION: Retrieves the style collection for a specified range of styled string. It takes start and length as parameters, and an optional styledKey for specific styles. The method returns an array of SpanStyle objects. It's crucial to ensure that the start and length parameters do not exceed the bounds of the styled string.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-universal-styled-string.md#_snippet_10

LANGUAGE: typescript
CODE:
```
getStyles(start: number , length: number , styledKey?: StyledStringKey): Array<SpanStyle>
```

--------------------------------

TITLE: TipsDialog Component Initialization
DESCRIPTION: This snippet demonstrates the basic initialization of the TipsDialog component, showcasing the mandatory controller and imageRes properties, along with optional parameters like imageSize, title, content, and button configurations. It highlights the flexibility in customizing the dialog's appearance and functionality.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-Dialog.md#_snippet_0

LANGUAGE: typescript
CODE:
```
new TipsDialog({
  controller: customDialogController,
  imageRes: imageResource,
  imageSize: { width: 100, height: 100 },
  title: 'Dialog Title',
  content: 'This is the dialog content.',
  primaryButton: {
    text: 'OK',
    action: () => { /* handle OK action */ }
  },
  secondaryButton: {
    text: 'Cancel',
    action: () => { /* handle Cancel action */ }
  }
});
```

--------------------------------

TITLE: InnerFullScreenLaunchComponent Usage
DESCRIPTION: Demonstrates how to use the InnerFullScreenLaunchComponent to launch atomic services with a controller and handle incoming data.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-InnerFullScreenLaunchComponent-sys.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
## InnerFullScreenLaunchComponent

### Description
Allows launching atomic services in a full-screen or embedded manner. The behavior depends on whether the service is authorized for embedded execution.

### Method
Constructor

### Endpoint
N/A (Component Constructor)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
*   **content** (Callback<void>) - Required - The content to be displayed within the component. This is a builder parameter.
*   **controller** ([LaunchController](#launchcontroller)) - Required - The controller for launching atomic services.
*   **onReceive** (Callback<Record<string, Object>>) - Optional - A callback triggered when the embedded atomic service calls APIs via [Window](../../../windowmanager/application-window-stage.md).

### Request Example
```typescript
import { InnerFullScreenLaunchComponent, LaunchController } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  @Builder
  ColumChild() {
    Column() {
      Text('InnerFullScreenLaunchComponent').fontSize(16).margin({top: 100})
      Button('start 日出日落')
        .onClick(()=>{
          let appId1: string = '576****************';
          this.controller.launchAtomicService(appId1, {});
        }).height(30).width('50%').margin({top: 50})
      Button('start 充值')
        .onClick(()=>{
          let appId2: string = '576****************';
          this.controller.launchAtomicService(appId2, {});
        }).height(30).width('50%').margin({top: 50})
    }.backgroundColor(Color.Pink).height('100%').width('100%')
  }
  controller: LaunchController = new LaunchController();

  build() {
    Column() {
      InnerFullScreenLaunchComponent({
          content: this.ColumChild,
          controller: this.controller,
          onReceive: (data) => {
            console.info("onReceive, data: " + data['ohos.atomicService.window']);
          }
        })
    }
    .width('100%').height('100%')
  }
}
```

### Response
#### Success Response (N/A for component constructor)

#### Response Example
(Component rendering, no direct response body for constructor)

```

--------------------------------

TITLE: ArkUI Geometry Transition Example
DESCRIPTION: This ArkUI TypeScript example demonstrates the usage of geometryTransition for shared element transitions. It showcases how to apply the transition to different components and use it with explicit animations for visual effects.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-transition-animation-geometrytransition-sys.md#_snippet_0

LANGUAGE: typescript
CODE:
```
// xxx.ets
@Entry
@Component
struct Index {
  @State isShow: boolean = false

  build() {
    Stack({ justifyContent: HorizontalAlign.Center }) {
      if (this.isShow) {
        Image($r('app.media.pic'))
          .autoResize(false)
          .clip(true)
          .width(300)
          .height(400)
          .offset({ y: 100 })
          .geometryTransition("picture", { hierarchyStrategy: TransitionHierarchyStrategy.ADAPTIVE })
          .transition(TransitionEffect.OPACITY)
      } else {
        // geometryTransition此处绑定的是容器，那么容器内的子组件需设为相对布局跟随父容器变化，
        // 套多层容器为了说明相对布局约束传递
        Column() {
          Column() {
            Image($r('app.media.icon'))
              .width('100%').height('100%')
          }.width('100%').height('100%')
        }
        .width(80)
        .height(80)
        // geometryTransition会同步圆角，但仅限于geometryTransition绑定处，此处绑定的是容器
        // 则对容器本身有圆角同步而不会操作容器内部子组件的borderRadius
        .borderRadius(20)
        .clip(true)
        .geometryTransition("picture", { hierarchyStrategy: TransitionHierarchyStrategy.ADAPTIVE })
        // transition保证组件离场不被立即析构，可设置其他转场效果
        .transition(TransitionEffect.OPACITY)
      }
    }
    .onClick(() => {
      this.getUIContext()?.animateTo({ duration: 1000 }, () => {
        this.isShow = !this.isShow
      })
    })
  }
}
```

--------------------------------

TITLE: Handle Pull-to-Refresh Start (ArkTS)
DESCRIPTION: Registers a callback function that is invoked when the component enters the refreshing state. This event is available from API version 11 and supported in atomic services.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ts-container-refresh.md#_snippet_12

LANGUAGE: typescript
CODE:
```
onRefreshing(callback: () => void)
```

--------------------------------

TITLE: ArkTS RichEditor Configuration with Styles
DESCRIPTION: Shows the basic configuration of a RichEditor component, including setting its border, color, dimensions, and margins. It also includes a handler for when the editor is ready.

SOURCE: https://github.com/xzhao65/arkts_rag/blob/main/arkui-ts/ohos-arkui-advanced-SelectionMenu.md#_snippet_9

LANGUAGE: typescript
CODE:
```
RichEditor(this.options)
  .onReady(() => {
    this.controller.addTextSpan(this.message, { style: { fontColor: Color.Orange, fontSize: 30 } });
    this.controller.addTextSpan(this.message, { style: { fontColor: Color.Black, fontSize: 25 } });
  })
  .borderWidth(1)
  .borderColor(Color.Red)
  .width(200)
  .height(200)
  .margin(10)
```
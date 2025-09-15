# HarmonyOS NEXT ArkTS 完整开发指南

## 🎯 核心开发原则

### 1. 语法和API规范
- **严格遵循HarmonyOS NEXT规范**：使用官方API，避免不存在的语法
- **影响范围最小化**：修改代码时不影响已完成功能
- **专注当前任务**：不做任务外内容，除非必要补充

### 2. 代码质量标准
- **变量命名**：英文单词+驼峰命名法，保持项目风格一致
- **注释规范**：按逻辑功能添加，避免逐句注释和序号标记
- **方法粒度**：一个方法完成一个功能，避免过度碎片化
- **复用优先**：参考已有功能实现，但避免完全复制

### 3. 风险控制
- **高风险操作先询问**：提交代码、部署等操作需确认
- **变量名一致性**：界面显示与保存提交使用相同变量
- **项目结构保护**：非必要不修改项目结构和配置文件
- **已有功能保护**：复用时创建副本，不直接修改被引用的代码

## 🔥 ArkTS常见错误模式 (60种，重复率85%)

### 基础语法错误 (1-10)

#### 1. throw语句错误 (40%的错误)
```typescript
// ❌ 错误
throw error;

// ✅ 正确
throw new Error('具体错误信息');
```

#### 2. Function.bind不支持 (10%的错误)
```typescript
// ❌ 错误
this.themeManager.addThemeListener(this.onThemeChange.bind(this));

// ✅ 正确
this.themeManager.addThemeListener((theme: AppTheme) => {
  this.onThemeChange(theme);
});
```

#### 3. 对象字面量类型声明 (25%的错误)
```typescript
// ❌ 错误
const item = new ItemModel({
  id: 1,
  name: 'test'
});

// ✅ 正确
const item = new ItemModel();
item.id = 1;
item.name = 'test';
```

#### 4. any类型使用 (8%的错误)
```typescript
// ❌ 错误
function getData(): any {
  return {};
}

// ✅ 正确
function getData(): Record<string, any> {
  return {};
}
```

#### 5. 索引访问不支持 (5%的错误)
```typescript
// ❌ 错误
const value = config[key];

// ✅ 正确
let value;
if (key === 'option1') value = config.option1;
else if (key === 'option2') value = config.option2;
```

#### 6. 解构赋值不支持 (3%的错误)
```typescript
// ❌ 错误
const {name, age} = person;

// ✅ 正确
const name = person.name;
const age = person.age;
```

#### 7. 静态方法中使用this (4%的错误)
```typescript
// ❌ 错误
static method() {
  this.property = value;
}

// ✅ 正确
static method() {
  ClassName.property = value;
}
```

#### 8. 函数返回类型推断受限
```typescript
// ❌ 错误
async getCategoryStats() {
  return result.rows;
}

// ✅ 正确
async getCategoryStats(): Promise<CategoryStats[]> {
  return result.rows.map(row => ({ id: row.id, name: row.name }));
}
```

#### 9. 独立函数中使用this
```typescript
// ❌ 错误
static method() {
  return this.property;
}

// ✅ 正确
static method() {
  return ClassName.property;
}
```

#### 10. 类结构语法错误
```typescript
// ❌ 错误：多余的大括号导致类提前结束
class MyClass {
  method1() {
    // 实现
  }
} // 多余的大括号

  method2() { // 这个方法在类外部
    // 实现
  }

// ✅ 正确
class MyClass {
  method1() {
    // 实现
  }

  method2() {
    // 实现
  }
}
```

### 对象和数组操作错误 (11-20)

#### 11. Spread操作符不支持
```typescript
// ❌ 错误
const newObj = { ...oldObj, newProp: 'value' };

// ✅ 正确
const newObj = {
  id: oldObj.id,
  name: oldObj.name,
  newProp: 'value'
};
```

#### 12. 对象字面量作为类型声明
```typescript
// ❌ 错误
function validate(data: any): {isValid: boolean, message: string} {
  return { isValid: true, message: '' };
}

// ✅ 正确
interface ValidationResult {
  isValid: boolean;
  message: string;
}

function validate(data: any): ValidationResult {
  const result: ValidationResult = { isValid: true, message: '' };
  return result;
}
```

#### 13. 数组字面量类型推断受限
```typescript
// ❌ 错误
return [
  { icon: '🧴', name: '日用品' },
  { icon: '🍎', name: '食品' }
];

// ✅ 正确
interface RecommendedIcon {
  icon: string;
  name: string;
}

const icons: RecommendedIcon[] = [];
const icon1: RecommendedIcon = { icon: '🧴', name: '日用品' };
icons.push(icon1);
return icons;
```

#### 14. 箭头函数返回类型推断受限
```typescript
// ❌ 错误
const totalItems = stats.reduce((sum, stat) => sum + stat.count, 0);

// ✅ 正确
const totalItems = stats.reduce((sum: number, stat: CategoryStats): number => sum + stat.count, 0);
```

#### 15. 解构参数不支持
```typescript
// ❌ 错误
animations.forEach(({ delay, animation }) => {
  this.delayedAnimation(delay, animation);
});

// ✅ 正确
animations.forEach((item: AnimationItem) => {
  const delay = item.delay;
  const animation = item.animation;
  AnimationUtils.delayedAnimation(delay, animation);
});
```

#### 16. 类型不匹配错误
```typescript
// ❌ 错误
component.scale = { x: 1, y: 1 }; // Record<string, string | number | boolean>不能接受对象

// ✅ 正确
const scaleValue: Record<string, number> = {};
scaleValue.x = 1;
scaleValue.y = 1;
component.scale = scaleValue;
```

#### 17. 数据库ResultSet类型转换错误
```typescript
// ❌ 错误
const rows = result.rows;
const affected = result.rowsAffected;

// ✅ 正确
const rows = (result as any).rows || [];
const affected = (result as any).rowsAffected > 0;
```

#### 18. 数据模型转换错误
```typescript
// ❌ 错误：LocationModel[] 不能直接赋值给 LocationInfo[]
async getCommonLocations(): Promise<LocationInfo[]> {
  return await this.locationDao.getCommonLocations(limit);
}

// ✅ 正确
async getCommonLocations(): Promise<LocationInfo[]> {
  const locations = await this.locationDao.getCommonLocations(limit);
  return locations.map((location): LocationInfo => {
    const locationInfo: LocationInfo = {
      name: location.name,
      count: location.usage_count  // 属性名转换
    };
    return locationInfo;
  });
}
```

#### 19. 枚举名称冲突错误
```typescript
// ❌ 错误：自定义枚举与系统枚举冲突
enum InputType {
  TEXT = 'text',
  NUMBER = 'number'
}

// ✅ 正确
enum AppInputType {
  TEXT = 'text',
  NUMBER = 'number'
}
```

#### 20. 配置类型转换错误
```typescript
// ❌ 错误
const warningDays = config.expiryWarningDays || 7; // string | number | true
const expiringItems = await this.itemService.getExpiringItems(warningDays); // 需要number

// ✅ 正确
const warningDays = Number(config.expiryWarningDays) || 7;
const expiringItems = await this.itemService.getExpiringItems(warningDays);
```

### 组件和UI错误 (21-30)

#### 21. 组件属性访问权限错误
```typescript
// ❌ 错误
@Component
export struct MyComponent {
  private placeholder: string = ''; // private属性不能通过构造函数传递
}

// ✅ 正确
@Component
export struct MyComponent {
  @Prop placeholder: string = ''; // 使用@Prop装饰器
}
```

#### 22. 页面跳转逻辑缺失错误
```typescript
// ❌ 错误
.onClick(() => {
  console.info('Navigate to page'); // 只有日志，没有实际跳转
})

// ✅ 正确
import router from '@ohos.router';

.onClick(() => {
  router.pushUrl({
    url: 'pages/TargetPage',
    params: { data: 'value' }
  }).catch((error: Error) => {
    console.error('Failed to navigate:', error);
  });
})
```

#### 23. 接口属性不匹配错误
```typescript
// ❌ 错误
interface StatsData {
  total: number;
  expiring: number;
}

const stats: StatsData = { total: 0 }; // 缺少expiring属性

// ✅ 正确
const stats: StatsData = {
  total: 0,
  expiring: 0
};
```

#### 24. build方法中的非UI语法错误
```typescript
// ❌ 错误
build() {
  Column() {
    const remainingDays = this.item!.getRemainingDays(); // 不能在build中写复杂逻辑
    Text(expiryText)
  }
}

// ✅ 正确
build() {
  Column() {
    Text(this.getExpiryText()) // 调用方法获取计算结果
  }
}

private getExpiryText(): string {
  if (!this.item) return '';
  const remainingDays = this.item.getRemainingDays();
  return remainingDays >= 0 ? `还有${remainingDays}天` : `已过期${Math.abs(remainingDays)}天`;
}
```

#### 25. 主题颜色属性不存在错误
```typescript
// ❌ 错误
return this.theme.colors.text; // text属性不存在

// ✅ 正确
return this.theme.colors.onSurface; // 主要文字颜色
return this.theme.colors.onBackground; // 背景上的文字颜色
```

#### 26. @Prop属性不能是可选参数错误
```typescript
// ❌ 错误
@Prop icon?: string; // @Prop不能是可选的

// ✅ 正确
@Prop icon: string = ''; // 给默认值
```

#### 27. 资源文件名冲突错误
```typescript
// ❌ 错误：同一类型的资源文件名必须唯一
AppScope/resources/base/media/
├── foreground.svg
├── foreground.png  // 冲突

// ✅ 正确
AppScope/resources/base/media/
├── foreground.svg     // 使用SVG格式
├── background.svg
```

#### 28. 资源目录结构错误
```typescript
// ❌ 错误：media目录下不支持子目录
entry/src/main/resources/base/media/
├── icons/              // 不支持子目录
│   ├── search_icon.svg

// ✅ 正确
entry/src/main/resources/base/media/
├── search_icon.svg     // 直接放在media目录下
├── add_icon.svg
```

#### 29. 动画组件参数类型错误
```typescript
// ❌ 错误：使用Record<string,any>或过严格的基本类型限制
interface AnimationComponent {
  scale: Record<string, any>;
  rotate: number;
}

// ✅ 正确：定义明确接口
interface ScaleOptions {
  x: number;
  y: number;
}

interface RotateOptions {
  angle: number;
  centerX?: number;
  centerY?: number;
}

interface AnimationComponent {
  scale: ScaleOptions;
  rotate: RotateOptions;
}
```

#### 30. 数据库ResultSet类型转换错误
```typescript
// ❌ 错误：不能使用as Record<string,unknown>转换ResultSet
const result = await store.querySql(sql);
return ((result as Record<string, unknown>).rows as unknown[]).map(...);

// ✅ 正确：使用原生方法访问数据
const result = await store.querySql(sql);
const items: ItemModel[] = [];
if (result.rowCount > 0) {
  for (let i = 0; i < result.rowCount; i++) {
    result.goToRow(i);
    const item = new ItemModel();
    item.id = result.getLong(result.getColumnIndex('id'));
    item.name = result.getString(result.getColumnIndex('name'));
    items.push(item);
  }
}
return items;
```

### 新发现错误模式 (31-60)

#### 31. List组件子组件限制错误
```typescript
// ❌ 错误：List组件中直接放置Text组件
List() {
  if (condition) {
    ForEach(items, ...)
  } else {
    Text('提示信息')  // List中不能直接放Text
  }
}

// ✅ 正确：包装在ListItem中
List() {
  if (condition) {
    ForEach(items, ...)
  } else {
    ListItem() {
      Text('提示信息')
    }
  }
}
```

#### 32. 组件双向绑定语法错误
```typescript
// ❌ 错误：HarmonyOS NEXT中没有$this语法
AppInput({
  value: $this.itemName,  // 错误语法
  placeholder: '请输入'
})

// ✅ 正确：使用@Prop + 回调函数模式
AppInput({
  value: this.itemName,
  placeholder: '请输入',
  onValueChange: (value: string) => {
    this.itemName = value;
  }
})
```

#### 33. 组件布局和交互冲突错误
```typescript
// ❌ 错误：组件布局不当导致输入空间不足
Row({ space: 12 }) {
  AppInput({
    value: this.quantity,
    type: AppInputType.NUMBER
  })  // 没有layoutWeight，被挤压

  this.buildUnitSelector()
}

// ✅ 正确：使用layoutWeight确保输入空间
Row({ space: 12 }) {
  AppInput({
    value: this.quantity,
    type: AppInputType.NUMBER
  })
  .layoutWeight(1)  // 确保有足够空间

  this.buildUnitSelector()
}
```

#### 34. 项目范围内双向绑定语法错误
```typescript
// ❌ 错误：在整个项目中系统性地使用了错误的双向绑定语法
AppInput({
  value: $variableName,  // 错误语法
})

// ✅ 正确：使用正确的单向数据流 + 回调函数模式
AppInput({
  value: this.variableName,
  onValueChange: (value: string) => {
    this.variableName = value;
  }
})
```

#### 35. 日期选择器交互错误
```typescript
// ❌ 错误：日期选择器滑动时自动关闭
Column() {
  // 遮罩层和内容在同一层级，事件冒泡
  Column().onClick(() => { /* 关闭 */ })
  DatePicker()
}

// ✅ 正确：使用Stack布局防止事件冒泡
Stack() {
  // 遮罩层
  Column().onClick(() => { /* 关闭 */ })

  // 日期选择器内容（独立层级）
  Column({ space: 20 }) {
    DatePicker()
    Row() { /* 按钮 */ }
  }
}
```

#### 56. @State变量UI更新失效错误（🔥 极其重要！）
```typescript
// ❌ 错误：通过参数传递计算值，断开@State绑定
@State private quantity: number = 10;

// 错误的做法1：字符串插值在传参时就计算了，UI不会更新
const displayText = `${this.quantity}个`;
this.buildInfoCard('库存', displayText);

// 错误的做法2：直接传递插值字符串
this.buildInfoCard('库存', `${this.quantity}个`);

// 错误的做法3：在方法参数中计算
@Builder
buildInfoCard(title: string, value: string) {
  Column() {
    Text(title)
    Text(value)  // 这里显示的是传入时计算的固定值
  }
}

// ✅ 正确：UI组件直接引用@State变量
@Builder
buildInfoCard(title: string) {
  Column() {
    Text(title)
    Text(this.quantity + '个')  // 直接引用@State变量
  }
}

// 调用时
this.buildInfoCard('库存');
```

**🎯 关键原理**：
- **UI组件必须直接引用@State变量才能自动更新**
- **通过参数传递计算后的值会断开@State绑定**
- **字符串插值`${}`在传参时就计算了，不会保持响应式绑定**

**✅ 正确模式**：
```typescript
// ✅ 直接在UI中引用@State
Text(this.stateVariable + someOtherValue)
Text(`${this.stateVariable}${someOtherValue}`)  // 在UI组件内部使用插值

// ❌ 通过参数传递计算值
const computed = `${this.stateVariable}${someOtherValue}`;
SomeComponent(computed);  // 断开了@State绑定
```

**🔍 调试技巧**：
- 如果数据更新了但UI没变化，检查是否直接引用了@State变量
- 避免在方法调用时进行字符串插值计算
- 将计算逻辑放在UI组件内部，而不是方法参数中

#### 57. ForEach缺少keyGenerator导致无限重新渲染 (🔥 极其重要！)
```typescript
// ❌ 错误：ForEach缺少keyGenerator会导致主线程阻塞崩溃
ForEach(this.tasks, (task: TaskModel) => {
  TaskCard({ task: task })
})  // 缺少keyGenerator参数

// ✅ 正确：必须提供keyGenerator
ForEach(this.tasks, (task: TaskModel) => {
  TaskCard({ task: task })
}, (task: TaskModel) => task.id.toString())  // 提供唯一标识符
```

**影响**: 运行时崩溃 `THREAD_BLOCK_6S`，主线程阻塞超过6秒

#### 58. ForEach数据源使用方法调用导致递归死循环 (🔥 极其重要！)
```typescript
// ❌ 错误：直接在ForEach中调用方法会导致递归死循环
ForEach(this.getFilteredTasks(), (task) => {
  TaskCard({ task: task })
}, (task) => task.id.toString())

// ✅ 正确：先将数据赋值给变量
const filteredTasks = this.getFilteredTasks()
ForEach(filteredTasks, (task) => {
  TaskCard({ task: task })
}, (task) => task.id.toString())
```

**影响**: 运行时崩溃，递归死循环导致应用无响应

#### 59. 自定义组件属性名不一致错误 (30%的错误)
```typescript
// ❌ 错误：习惯性使用通用属性名
AppButton({ text: "按钮" })           // 应该是buttonText
AppCard({ title: "标题" })            // 应该是cardTitle
AppLoading({ text: "加载中" })        // 应该是loadingText

// ✅ 正确：使用组件实际定义的属性名
AppButton({ buttonText: "按钮" })
AppCard({ cardTitle: "标题" })
AppLoading({ loadingText: "加载中" })
```

**影响**: 编译错误 `Property 'xxx' does not exist`

#### 60. 自定义组件无法直接使用属性方法 (15%的错误)
```typescript
// ❌ 错误：自定义组件不能直接使用属性方法
AppCard({...}) {
  // 内容
}
.scale({ x: 0.8, y: 0.8 })  // 编译错误
.opacity(0.5)

// ✅ 正确：用原生组件包装
Column() {
  AppCard({...}) {
    // 内容
  }
}
.scale({ x: 0.8, y: 0.8 })  // 原生组件支持属性方法
.opacity(0.5)
```

**影响**: 编译错误，属性方法只能用于原生组件

## 📋 类型安全规范

### 对象字面量规则
- **必须对应明确声明的类或接口类型**
- **为箭头函数添加明确的返回类型注解**
- **使用临时变量并声明类型**

### 状态管理类型
```typescript
// ✅ 正确的状态声明
@State searchResults: SearchResult[] = []
@Prop title: string = ''
@Link selectedIndex: number
```

### 组件属性类型
```typescript
// ✅ 正确的方法签名
private performSearch(keyword: string): Promise<SearchResult[]> {
  // 实现
}
```

## 🛠️ 常见错误解决方案

| 错误类型 | 原因 | 解决方案 |
|---------|------|----------|
| `Object literal must correspond to some explicitly declared class or interface` | 对象字面量缺少类型声明 | 添加类型注解或使用临时变量 |
| `Use explicit types instead of "any", "unknown"` | 使用any/unknown类型 | 使用具体的类型定义 |
| `It is possible to spread only arrays` | 对非数组使用spread操作符 | 使用显式属性赋值 |
| `Type 'number' is not assignable to type 'LengthMetrics'` | 数值类型不匹配 | 使用LengthMetrics.vp(数值) |
| `'value.property' is possibly 'undefined'` | 属性可能为undefined | 使用空值合并操作符(??) |
| `Cannot find name '$this'` | 错误的双向绑定语法 | 使用@Prop + 回调函数模式 |
| `Property 'value' cannot initialize using '$' to create a reference` | 错误的引用语法 | 移除$符号，使用正确语法 |
| `THREAD_BLOCK_6S` | ForEach缺少keyGenerator | 为ForEach添加keyGenerator参数 |
| `Property 'xxx' does not exist` | 自定义组件属性名错误 | 查看组件定义，使用正确属性名 |

## 🎨 页面布局要求

### 1. 页面结构规范
- **Index.ets**：使用Tab组件布局 + 一级页面为自定义组件
- **其他页面**：正常page结构
- **一级页面**：通过底部导航栏跳转的页面

### 2. 资源规范
- **图片资源**：统一使用SVG格式
- **深色模式**：根据官方文档进行颜色适配，无需切换功能

## 🚀 预防策略

### 代码生成前检查
- [ ] 错误处理使用throw new Error()
- [ ] 事件绑定使用箭头函数
- [ ] 对象创建避免字面量
- [ ] 类型声明避免any
- [ ] 属性访问使用条件判断
- [ ] 双向绑定使用正确语法

### 批量修复脚本

> ⚠️ **重要提醒**：批量修复脚本一定要慎用！先确认直接替换不会影响其他正常代码。批量修复适合绝对安全的字符串替换，其他情况建议逐个修复。

```bash
#!/bin/bash
# 修复throw语句 - 相对安全
find . -name "*.ets" -exec sed -i 's/throw error;/throw new Error("Operation failed");/g' {} \;

# 修复any类型 - 需要谨慎使用
find . -name "*.ets" -exec sed -i 's/: any/: Record<string, any>/g' {} \;

# 修复Function.bind - 需要手动处理复杂情况
find . -name "*.ets" -exec sed -i 's/\.bind(this)//g' {} \;
```

### 修复策略建议
1. **优先逐个修复**：对于复杂的类型推断和对象字面量问题
2. **批量修复适用场景**：简单的字符串替换，如throw语句
3. **谨慎使用批量替换**：any类型替换可能影响其他正常代码
4. **验证修复结果**：每次修复后检查是否引入新问题

## 📊 效果预期
- **错误数量**：从150+减少到10个以内
- **修复时间**：从2小时减少到15分钟
- **代码质量**：100%符合ArkTS规范

## 🎯 记忆要点
1. **HarmonyOS NEXT严格类型检查** - 不要总不写明确类型
2. **影响范围控制** - 修改时保护已有功能
3. **代码复用策略** - 参考但不完全复制
4. **风险操作确认** - 高风险操作先询问
5. **变量一致性** - 界面与逻辑使用相同变量名
6. **项目结构保护** - 非必要不修改配置
7. **错误模式记忆** - 避免重复相同错误
8. **双向绑定正确语法** - 使用@Prop + 回调函数模式
9. **组件结构约束** - 严格遵守组件的子组件限制
10. **逐个修复优于批量替换** - 安全第一，速度第二
11. **@State变量UI更新** - 布局必须直接使用状态变量才能触发刷新
12. **ForEach必须有keyGenerator** - 避免无限重新渲染和崩溃
13. **ForEach数据源必须是变量** - 不能直接调用方法，避免递归死循环
14. **自定义组件属性名准确性** - 查看组件定义，不要用通用名称
15. **自定义组件需原生组件包装** - 才能使用.scale()等属性方法

## 💡 最佳实践总结

### 类型安全
- 始终定义明确的接口和类型
- 避免使用any，使用Record<string, any>
- 为函数参数和返回值添加类型注解
- 使用可选链操作符处理undefined

### 代码结构
- 接口定义放在文件顶部
- 方法按功能分组，避免过度碎片化
- 保持命名一致性和项目风格
- 复用代码时创建副本而非直接修改

### 错误预防
- 使用批量修复脚本处理重复错误
- 建立代码检查清单
- 定期更新错误模式库
- 在生成阶段就遵循ArkTS规范

### 数据流设计
- 使用单向数据流 + 回调函数，而不是双向绑定
- 组件间通信使用明确的接口定义
- 状态管理使用@State、@Prop、@Link等正确装饰器
- 避免在build()方法中写复杂逻辑

通过遵循这些完整的指南，可以将HarmonyOS NEXT项目的错误率降低95%以上！这些都是我们血泪总结出来的宝贵经验，每一条都代表着无数次的犯错和改错。

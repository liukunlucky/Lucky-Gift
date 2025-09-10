import relationalStore from '@ohos.data.relationalStore';
import { BudgetCalculation, HolidayCountdown } from '../model/NewDataModels';
import { NewDatabaseManager } from './NewDatabaseManager';

interface HolidayWithDays extends HolidayCountdown {
  daysUntil?: number;
}

interface ToolsStatistics {
  totalBudgetCalculations: number;
  totalHolidayCountdowns: number;
  averageBudgetPerCalculation: number;
  mostUsedTool: string;
}

export class ToolsDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // ==================== 预算计算管理 ====================
  
  // 创建预算计算记录
  async createBudgetCalculation(calculation: BudgetCalculation): Promise<string> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const id = this.dbManager.generateId();
    const now = this.dbManager.getCurrentTimestamp();

    const valueBucket: relationalStore.ValuesBucket = {
      id: id,
      name: calculation.name,
      title: calculation.title || null,
      total_budget: calculation.totalBudget,
      number_of_people: calculation.numberOfPeople || null,
      budget_per_person: calculation.budgetPerPerson || null,
      items: JSON.stringify(calculation.items || []),
      created_at: now
    };

    await rdbStore.insert('budget_calculations', valueBucket);
    return id;
  }

  // 获取所有预算计算记录
  async getAllBudgetCalculations(): Promise<BudgetCalculation[]> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM budget_calculations ORDER BY created_at DESC'
    );

    const calculations: BudgetCalculation[] = [];
    while (resultSet.goToNextRow()) {
      calculations.push(this.parseBudgetCalculationFromResultSet(resultSet));
    }
    resultSet.close();

    return calculations;
  }

  // 根据ID获取预算计算记录
  async getBudgetCalculationById(id: string): Promise<BudgetCalculation | null> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const resultSet = await rdbStore.querySql(
      'SELECT * FROM budget_calculations WHERE id = ?',
      [id]
    );

    let calculation: BudgetCalculation | null = null;
    if (resultSet.goToFirstRow()) {
      calculation = this.parseBudgetCalculationFromResultSet(resultSet);
    }
    resultSet.close();

    return calculation;
  }

  // 删除预算计算记录
  async deleteBudgetCalculation(id: string): Promise<void> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    const predicates = new relationalStore.RdbPredicates('budget_calculations');
    predicates.equalTo('id', id);

    await rdbStore.delete(predicates);
  }

  // ==================== 节日倒计时管理 ====================
  
  // 获取所有节日倒计时
  async getAllHolidayCountdowns(): Promise<HolidayCountdown[]> {
    // 返回预定义的节日列表
    const currentYear = new Date().getFullYear();
    const nextYear = currentYear + 1;
    
    const holidays: HolidayCountdown[] = [
      {
        id: 'new_year',
        name: '元旦',
        date: `${nextYear}-01-01`,
        description: '新年第一天',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      },
      {
        id: 'spring_festival',
        name: '春节',
        date: `${nextYear}-02-10`, // 示例日期，实际需要农历计算
        description: '中国传统新年',
        isImportant: true,
        reminderDays: 14,
        createdAt: new Date().toISOString()
      },
      {
        id: 'valentines_day',
        name: '情人节',
        date: `${nextYear}-02-14`,
        description: '爱情的节日',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      },
      {
        id: 'womens_day',
        name: '妇女节',
        date: `${nextYear}-03-08`,
        description: '国际妇女节',
        isImportant: true,
        reminderDays: 3,
        createdAt: new Date().toISOString()
      },
      {
        id: 'mothers_day',
        name: '母亲节',
        date: `${nextYear}-05-11`, // 示例日期，实际是5月第二个周日
        description: '感恩母亲的节日',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      },
      {
        id: 'childrens_day',
        name: '儿童节',
        date: `${nextYear}-06-01`,
        description: '属于孩子们的节日',
        isImportant: true,
        reminderDays: 3,
        createdAt: new Date().toISOString()
      },
      {
        id: 'fathers_day',
        name: '父亲节',
        date: `${nextYear}-06-15`, // 示例日期，实际是6月第三个周日
        description: '感恩父亲的节日',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      },
      {
        id: 'mid_autumn',
        name: '中秋节',
        date: `${nextYear}-09-17`, // 示例日期，实际需要农历计算
        description: '团圆的节日',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      },
      {
        id: 'national_day',
        name: '国庆节',
        date: `${nextYear}-10-01`,
        description: '中华人民共和国国庆节',
        isImportant: true,
        reminderDays: 3,
        createdAt: new Date().toISOString()
      },
      {
        id: 'christmas',
        name: '圣诞节',
        date: `${nextYear}-12-25`,
        description: '西方传统节日',
        isImportant: true,
        reminderDays: 7,
        createdAt: new Date().toISOString()
      }
    ];

    // 计算距离天数
    const now = new Date();
    return holidays.map(holiday => {
      const holidayDate = new Date(holiday.date);
      const diffTime = holidayDate.getTime() - now.getTime();
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      
      const result: HolidayWithDays = {
        id: holiday.id,
        name: holiday.name,
        date: holiday.date,
        description: holiday.description,
        isImportant: holiday.isImportant,
        reminderDays: holiday.reminderDays,
        createdAt: holiday.createdAt,
        daysUntil: diffDays > 0 ? diffDays : 0
      };
      return result;
    }).sort((a, b) => (a.daysUntil || 0) - (b.daysUntil || 0));
  }

  // 获取即将到来的节日（30天内）
  async getUpcomingHolidays(days: number = 30): Promise<HolidayCountdown[]> {
    const allHolidays = await this.getAllHolidayCountdowns();
    return allHolidays.filter(holiday => 
      holiday.daysUntil !== undefined && holiday.daysUntil <= days && holiday.daysUntil > 0
    );
  }

  // 根据分类获取节日
  async getHolidaysByCategory(category: string): Promise<HolidayCountdown[]> {
    const allHolidays = await this.getAllHolidayCountdowns();
    // 由于HolidayCountdown接口没有category属性，暂时返回所有节日
    return allHolidays;
  }

  // ==================== 工具统计 ====================
  
  // 获取工具使用统计
  async getToolsStatistics(): Promise<ToolsStatistics> {
    const rdbStore = this.dbManager.getRdbStore();
    if (!rdbStore) throw new Error('数据库未初始化');

    // 获取预算计算记录总数
    const budgetResult = await rdbStore.querySql(
      'SELECT COUNT(*) as count FROM budget_calculations'
    );
    let totalBudgetCalculations = 0;
    if (budgetResult.goToFirstRow()) {
      totalBudgetCalculations = budgetResult.getLong(0);
    }
    budgetResult.close();

    // 获取即将到来的节日数量
    const upcomingHolidays = await this.getUpcomingHolidays();

    const result: ToolsStatistics = {
      totalBudgetCalculations,
      totalHolidayCountdowns: upcomingHolidays.length,
      averageBudgetPerCalculation: 0, // 暂时设为0，可以后续计算
      mostUsedTool: '预算计算器' // 暂时设为默认值
    };
    return result;
  }

  // ==================== 私有方法 ====================
  
  private parseBudgetCalculationFromResultSet(resultSet: relationalStore.ResultSet): BudgetCalculation {
    const itemsStr = resultSet.getString(resultSet.getColumnIndex('items'));
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      title: resultSet.getString(resultSet.getColumnIndex('title')) || undefined,
      totalBudget: resultSet.getDouble(resultSet.getColumnIndex('total_budget')),
      numberOfPeople: resultSet.getLong(resultSet.getColumnIndex('number_of_people')) || undefined,
      budgetPerPerson: resultSet.getDouble(resultSet.getColumnIndex('budget_per_person')) || undefined,
      items: itemsStr ? JSON.parse(itemsStr) : [],
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
    };
  }
}
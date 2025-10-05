import { NewDatabaseManager } from '../database/NewDatabaseManager';
import relationalStore from '@ohos.data.relationalStore';

export interface ScanHistoryItem {
  id?: number;
  barcode: string;           // 条形码
  goodsName: string;         // 商品名称
  brand: string;             // 品牌/商标名称
  price: string;             // 参考价格
  image: string;             // 图片地址
  scanTime: string;          // 扫描时间
  
  // 扩展字段 - 包含API返回的完整信息
  flag?: string;             // 标识
  remark?: string;           // 备注
  manuName?: string;         // 厂商
  spec?: string;             // 规格
  goodsType?: string;        // 商品分类
  sptmImg?: string;          // 条码图片
  ycg?: string;              // 原产地
  engName?: string;          // 英文名
  note?: string;             // 备注信息
  ret_code?: string;         // 返回码
}

export class ScanHistoryDAO {
  private dbManager: NewDatabaseManager;

  constructor(dbManager: NewDatabaseManager) {
    this.dbManager = dbManager;
  }

  // 创建扫描历史表
  static getCreateTableSQL(): string {
    return `
      CREATE TABLE IF NOT EXISTS scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT NOT NULL,
        goodsName TEXT,
        brand TEXT,
        price TEXT,
        image TEXT,
        scanTime TEXT NOT NULL,
        flag TEXT,
        remark TEXT,
        manuName TEXT,
        spec TEXT,
        goodsType TEXT,
        sptmImg TEXT,
        ycg TEXT,
        engName TEXT,
        note TEXT,
        ret_code TEXT,
        UNIQUE(barcode)
      )
    `;
  }

  // 添加扫描记录
  async addScanHistory(item: ScanHistoryItem): Promise<boolean> {
    try {
      const store = this.dbManager.getRdbStore();
      if (!store) {
        console.error('数据库未初始化');
        return false;
      }

      // 检查是否已存在相同条形码的记录
      const existingRecord = await this.getScanHistoryByBarcode(item.barcode);
      
      if (existingRecord) {
        // 更新现有记录
        const updateSql = `
          UPDATE scan_history 
          SET goodsName = ?, brand = ?, price = ?, image = ?, scanTime = ?,
              flag = ?, remark = ?, manuName = ?, spec = ?, goodsType = ?,
              sptmImg = ?, ycg = ?, engName = ?, note = ?, ret_code = ?
          WHERE barcode = ?
        `;
        await store.executeSql(updateSql, [
          item.goodsName || '',
          item.brand || '',
          item.price || '',
          item.image || '',
          item.scanTime,
          item.flag || '',
          item.remark || '',
          item.manuName || '',
          item.spec || '',
          item.goodsType || '',
          item.sptmImg || '',
          item.ycg || '',
          item.engName || '',
          item.note || '',
          item.ret_code || '',
          item.barcode
        ]);
      } else {
        // 插入新记录
        const insertSql = `
          INSERT INTO scan_history (barcode, goodsName, brand, price, image, scanTime,
                                   flag, remark, manuName, spec, goodsType, sptmImg,
                                   ycg, engName, note, ret_code)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        await store.executeSql(insertSql, [
          item.barcode,
          item.goodsName || '',
          item.brand || '',
          item.price || '',
          item.image || '',
          item.scanTime,
          item.flag || '',
          item.remark || '',
          item.manuName || '',
          item.spec || '',
          item.goodsType || '',
          item.sptmImg || '',
          item.ycg || '',
          item.engName || '',
          item.note || '',
          item.ret_code || ''
        ]);
      }

      return true;
    } catch (error) {
      console.error('添加扫描历史失败:', error);
      return false;
    }
  }

  // 根据条形码获取扫描记录
  async getScanHistoryByBarcode(barcode: string): Promise<ScanHistoryItem | null> {
    try {
      const store = this.dbManager.getRdbStore();
      if (!store) {
        console.error('数据库未初始化');
        return null;
      }

      const sql = 'SELECT * FROM scan_history WHERE barcode = ?';
      const resultSet = await store.querySql(sql, [barcode]);
      
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        const item: ScanHistoryItem = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')) as number,
          barcode: resultSet.getString(resultSet.getColumnIndex('barcode')) as string,
          goodsName: resultSet.getString(resultSet.getColumnIndex('goodsName')) as string,
          brand: resultSet.getString(resultSet.getColumnIndex('brand')) as string,
          price: resultSet.getString(resultSet.getColumnIndex('price')) as string,
          image: resultSet.getString(resultSet.getColumnIndex('image')) as string,
          scanTime: resultSet.getString(resultSet.getColumnIndex('scanTime')) as string,
          flag: resultSet.getString(resultSet.getColumnIndex('flag')) as string,
          remark: resultSet.getString(resultSet.getColumnIndex('remark')) as string,
          manuName: resultSet.getString(resultSet.getColumnIndex('manuName')) as string,
          spec: resultSet.getString(resultSet.getColumnIndex('spec')) as string,
          goodsType: resultSet.getString(resultSet.getColumnIndex('goodsType')) as string,
          sptmImg: resultSet.getString(resultSet.getColumnIndex('sptmImg')) as string,
          ycg: resultSet.getString(resultSet.getColumnIndex('ycg')) as string,
          engName: resultSet.getString(resultSet.getColumnIndex('engName')) as string,
          note: resultSet.getString(resultSet.getColumnIndex('note')) as string,
          ret_code: resultSet.getString(resultSet.getColumnIndex('ret_code')) as string
        };
        resultSet.close();
        return item;
      }
      
      resultSet.close();
      return null;
    } catch (error) {
      console.error('查询扫描历史失败:', error);
      return null;
    }
  }

  // 获取最近的扫描记录
  async getRecentScans(limit: number = 10): Promise<ScanHistoryItem[]> {
    try {
      const store = this.dbManager.getRdbStore();
      if (!store) {
        console.error('数据库未初始化');
        return [];
      }

      const sql = 'SELECT * FROM scan_history ORDER BY scanTime DESC LIMIT ?';
      const resultSet = await store.querySql(sql, [limit.toString()]);
      
      const items: ScanHistoryItem[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          const item: ScanHistoryItem = {
            id: resultSet.getLong(resultSet.getColumnIndex('id')) as number,
            barcode: resultSet.getString(resultSet.getColumnIndex('barcode')) as string,
            goodsName: resultSet.getString(resultSet.getColumnIndex('goodsName')) as string,
            brand: resultSet.getString(resultSet.getColumnIndex('brand')) as string,
            price: resultSet.getString(resultSet.getColumnIndex('price')) as string,
            image: resultSet.getString(resultSet.getColumnIndex('image')) as string,
            scanTime: resultSet.getString(resultSet.getColumnIndex('scanTime')) as string,
            flag: resultSet.getString(resultSet.getColumnIndex('flag')) as string,
            remark: resultSet.getString(resultSet.getColumnIndex('remark')) as string,
            manuName: resultSet.getString(resultSet.getColumnIndex('manuName')) as string,
            spec: resultSet.getString(resultSet.getColumnIndex('spec')) as string,
            goodsType: resultSet.getString(resultSet.getColumnIndex('goodsType')) as string,
            sptmImg: resultSet.getString(resultSet.getColumnIndex('sptmImg')) as string,
            ycg: resultSet.getString(resultSet.getColumnIndex('ycg')) as string,
            engName: resultSet.getString(resultSet.getColumnIndex('engName')) as string,
            note: resultSet.getString(resultSet.getColumnIndex('note')) as string,
            ret_code: resultSet.getString(resultSet.getColumnIndex('ret_code')) as string
          };
          items.push(item);
        } while (resultSet.goToNextRow());
      }
      
      resultSet.close();
      return items;
    } catch (error) {
      console.error('获取最近扫描记录失败:', error);
      return [];
    }
  }

  // 删除扫描记录
  async deleteScanHistory(id: number): Promise<boolean> {
    try {
      const store = this.dbManager.getRdbStore();
      if (!store) {
        console.error('数据库未初始化');
        return false;
      }

      const sql = 'DELETE FROM scan_history WHERE id = ?';
      await store.executeSql(sql, [id.toString()]);
      return true;
    } catch (error) {
      console.error('删除扫描历史失败:', error);
      return false;
    }
  }

  // 清空所有扫描记录
  async clearAllScanHistory(): Promise<boolean> {
    try {
      const store = this.dbManager.getRdbStore();
      if (!store) {
        console.error('数据库未初始化');
        return false;
      }

      const sql = 'DELETE FROM scan_history';
      await store.executeSql(sql);
      return true;
    } catch (error) {
      console.error('清空扫描历史失败:', error);
      return false;
    }
  }
}
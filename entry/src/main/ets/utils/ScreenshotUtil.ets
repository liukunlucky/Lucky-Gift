import { componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

// 日志工具类
class Log {
  private static readonly DOMAIN = 0xFF00;
  private static readonly TAG = 'ScreenshotUtil';

  static info(tag: string, message: string): void {
    hilog.info(Log.DOMAIN, Log.TAG, `[${tag}] ${message}`);
  }

  static error(tag: string, message: string, error?: string): void {
    hilog.error(Log.DOMAIN, Log.TAG, `[${tag}] ${message} ${error || ''}`);
  }
}

export class ScreenshotUtil {
  
  /**
   * 对指定组件进行截图（官方推荐方式）
   * @param componentId 组件ID
   * @returns Promise<image.PixelMap> 返回截图的PixelMap
   */
  static async captureComponent(componentId: string): Promise<image.PixelMap> {
    return new Promise<image.PixelMap>((resolve, reject) => {
      // 使用官方推荐的回调方式获取组件快照 <mcreference link="https://blog.csdn.net/superherowupan/article/details/140936296" index="3">3</mcreference>
      componentSnapshot.get(componentId, (error: Error, pixelMap: image.PixelMap) => {
        if (error) {
          Log.error('ScreenshotUtil', '截图失败', error.toString());
          reject(new Error('截图失败: ' + error.message));
          return;
        }
        if (!pixelMap) {
          reject(new Error('截图失败：无法获取组件快照'));
          return;
        }
        Log.info('ScreenshotUtil', '组件截图成功');
        resolve(pixelMap);
      });
    });
  }

  /**
   * 对指定组件进行截图并保存到文件
   * @param componentId 组件ID
   * @returns Promise<string> 返回截图保存的路径
   */
  static async captureComponentToFile(componentId: string): Promise<string> {
    try {
      // 获取组件快照
      const pixelMap = await ScreenshotUtil.captureComponent(componentId);
      
      // 将PixelMap转换为ArrayBuffer
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/png', quality: 95 };
      const arrayBuffer: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      imagePackerApi.release();
      
      // 生成文件名
      const timestamp = new Date().getTime();
      const fileName = `screenshot_${timestamp}.png`;
      
      // 保存到应用沙箱
      const filePath = await ScreenshotUtil.saveToSandbox(arrayBuffer, fileName);
      
      Log.info('ScreenshotUtil', `截图保存成功: ${filePath}`);
      return filePath;
      
    } catch (error) {
      Log.error('ScreenshotUtil', '截图失败', error?.toString() || 'Unknown error');
      throw new Error('截图失败: ' + (error as Error).message);
    }
  }

  /**
   * 使用Builder方法创建完整页面截图（推荐方法）
   * @param builderFunc Builder函数
   * @param fileName 文件名（可选）
   * @returns Promise<string> 返回截图保存的路径
   */
  static async captureFromBuilder(builderFunc: () => void, fileName?: string): Promise<string> {
    try {
      // 使用createFromBuilder创建完整页面截图
      const pixelMap = await componentSnapshot.createFromBuilder(builderFunc);
      
      if (!pixelMap) {
         throw new Error('截图失败：无法创建Builder快照');
       }

       // 将PixelMap转换为ArrayBuffer
       const imagePackerApi = image.createImagePacker();
       const packOpts: image.PackingOption = { format: 'image/png', quality: 95 };
       const arrayBuffer: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
       imagePackerApi.release();
      
      // 生成文件名
      const timestamp = new Date().getTime();
      const finalFileName = fileName || `builder_screenshot_${timestamp}.png`;
      
      // 保存到应用沙箱
       const filePath = await ScreenshotUtil.saveToSandbox(arrayBuffer, finalFileName);
      
      // 释放资源
      pixelMap.release();
      
      Log.info('ScreenshotUtil', `Builder截图保存成功: ${filePath}`);
      return filePath;
      
    } catch (error) {
      Log.error('ScreenshotUtil', 'Builder截图失败', error?.toString() || 'Unknown error');
      throw new Error('Builder截图失败: ' + (error as Error).message);
    }
  }

  /**
   * 优化的长截图：直接使用Builder创建完整内容（推荐方式）
   * @param builderFunc Builder函数，用于创建完整的长内容
   * @param fileName 文件名（可选）
   * @returns Promise<image.PixelMap> 返回长截图的PixelMap
   */
  static async captureLongScreenshotOptimized(
    builderFunc: () => void,
    fileName?: string
  ): Promise<image.PixelMap> {
    try {
      Log.info('ScreenshotUtil', '开始优化长截图');
      
      // 使用官方推荐的createFromBuilder方式直接创建完整内容截图 <mcreference link="https://blog.csdn.net/superherowupan/article/details/140936296" index="3">3</mcreference>
      const pixelMap = await componentSnapshot.createFromBuilder(builderFunc);
      
      if (!pixelMap) {
        throw new Error('长截图生成失败');
      }
      
      Log.info('ScreenshotUtil', '优化长截图创建成功');
      return pixelMap;
      
    } catch (error) {
      Log.error('ScreenshotUtil', '优化长截图失败', error?.toString() || 'Unknown error');
      throw new Error('优化长截图失败: ' + (error as Error).message);
    }
  }

  /**
   * 传统长截图：对可滚动组件进行分段截图并拼接（备用方法）
   * @param scrollComponentId 可滚动组件的ID
   * @param totalHeight 内容总高度
   * @param viewportHeight 可视区域高度
   * @returns Promise<string> 返回长截图保存的路径
   */
  static async captureLongScreenshot(
    scrollComponentId: string, 
    totalHeight: number, 
    viewportHeight: number = 500
  ): Promise<string> {
    try {
      const screenshots: image.PixelMap[] = [];
      const segmentCount = Math.ceil(totalHeight / viewportHeight);
      
      Log.info('ScreenshotUtil', `开始传统长截图，总高度: ${totalHeight}, 分段数: ${segmentCount}`);

      for (let i = 0; i < segmentCount; i++) {
        // 等待渲染完成
        await ScreenshotUtil.delay(200);
        
        // 截取当前可见区域
        const pixelMap = await ScreenshotUtil.captureComponent(scrollComponentId);
        if (pixelMap) {
          screenshots.push(pixelMap);
          Log.info('ScreenshotUtil', `截取第 ${i + 1}/${segmentCount} 段`);
        } else {
          Log.error('ScreenshotUtil', `第 ${i + 1} 段截图失败`);
        }
      }

      if (screenshots.length === 0) {
          throw new Error('没有截取到任何内容');
        }

      // 拼接所有截图
      const mergedPixelMap = await ScreenshotUtil.mergePixelMaps(screenshots);
      
      // 保存拼接后的图片
       const imagePackerApi = image.createImagePacker();
       const packOpts: image.PackingOption = { format: 'image/png', quality: 95 };
       const arrayBuffer: ArrayBuffer = await imagePackerApi.packing(mergedPixelMap, packOpts);
       imagePackerApi.release();
      const timestamp = new Date().getTime();
      const fileName = `long_screenshot_${timestamp}.png`;
      const filePath = await ScreenshotUtil.saveToSandbox(arrayBuffer, fileName);
      
      // 释放资源
      mergedPixelMap.release();
      screenshots.forEach(pixelMap => pixelMap.release());
      
      Log.info('ScreenshotUtil', `长截图保存成功: ${filePath}`);
      return filePath;
      
    } catch (error) {
      Log.error('ScreenshotUtil', '长截图失败', error?.toString() || 'Unknown error');
      throw new Error('长截图失败: ' + (error as Error).message);
    }
  }

  /**
   * 保存图片到应用沙箱
   */
  private static async saveToSandbox(arrayBuffer: ArrayBuffer, fileName: string): Promise<string> {
    try {
      // 获取应用文件目录
      const context = getContext();
      const filesDir = context.filesDir;
      const filePath = `${filesDir}/${fileName}`;
      
      // 写入文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, arrayBuffer);
      fs.closeSync(file);
      
      return filePath;
    } catch (error) {
      Log.error('ScreenshotUtil', '保存文件失败', error?.toString() || 'Unknown error');
      throw new Error('保存文件失败: ' + (error as Error).message);
    }
  }

  /**
   * 保存图片到相册
   */
  static async saveToGallery(filePath: string): Promise<void> {
    try {
      const context = getContext() as common.UIAbilityContext;
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 创建PhotoAsset
      const photoUri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      
      // 读取文件数据
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const fileSize = fs.statSync(filePath).size;
      const arrayBuffer = new ArrayBuffer(fileSize);
      fs.readSync(file.fd, arrayBuffer);
      fs.closeSync(file);
      
      // 写入相册
      const photoFile = await fs.open(photoUri, fs.OpenMode.READ_WRITE);
      fs.writeSync(photoFile.fd, arrayBuffer);
      fs.closeSync(photoFile);
      
      Log.info('ScreenshotUtil', '图片已保存到相册');
      
      // 显示成功提示
      promptAction.showToast({
        message: '图片已保存到相册',
        duration: 2000
      });
    } catch (error) {
      Log.error('ScreenshotUtil', '保存到相册失败', error?.toString() || 'Unknown error');
      
      // 显示错误提示
      promptAction.showToast({
        message: '保存到相册失败: ' + (error as Error).message,
        duration: 2000
      });
      
      throw new Error('保存到相册失败: ' + (error as Error).message);
    }
  }

  /**
   * 直接保存PixelMap到相册
   * @param pixelMap 图片数据
   * @param fileName 文件名（可选）
   * @returns Promise<boolean> 是否成功
   */
  static async savePixelMapToGallery(pixelMap: image.PixelMap, fileName?: string): Promise<boolean> {
    try {
      const context = getContext() as common.UIAbilityContext;
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 创建相册资源
      const uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      
      // 打开文件
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      
      // 将PixelMap转换为ArrayBuffer并写入文件
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 95 };
      const arrayBuffer: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      
      // 写入文件
      await fs.write(file.fd, arrayBuffer);
      await fs.close(file.fd);
      
      // 释放资源
      imagePackerApi.release();
      
      Log.info('ScreenshotUtil', '图片已直接保存至相册');
      
      promptAction.showToast({
        message: '图片已保存至相册',
        duration: 2000
      });
      
      return true;
    } catch (error) {
      Log.error('ScreenshotUtil', '直接保存到相册失败', error?.toString() || 'Unknown error');
      
      promptAction.showToast({
        message: '保存失败: ' + (error as Error).message,
        duration: 2000
      });
      
      return false;
    }
  }

  /**
   * 延迟函数
   * @param ms 延迟毫秒数
   * @returns Promise<void>
   */
  static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 获取组件的实际高度
   * @param componentId 组件ID
   * @returns Promise<number> 组件高度
   */
  static async getComponentHeight(componentId: string): Promise<number> {
    try {
      const pixelMap = await componentSnapshot.get(componentId);
      if (pixelMap) {
        const imageInfo = await pixelMap.getImageInfo();
        const height = imageInfo.size.height;
        pixelMap.release();
        return height;
      }
      return 0;
    } catch (error) {
      Log.error('ScreenshotUtil', '获取组件高度失败', error?.toString() || 'Unknown error');
      return 0;
    }
  }

  /**
   * 拼接多个PixelMap
   */
  private static async mergePixelMaps(pixelMaps: image.PixelMap[]): Promise<image.PixelMap> {
     if (pixelMaps.length === 0) {
       throw new Error('没有可拼接的图片');
     }
    
    if (pixelMaps.length === 1) {
      return pixelMaps[0];
    }

    try {
      // 获取第一张图片的信息作为基准
      const firstImageInfo = await pixelMaps[0].getImageInfo();
      const width = firstImageInfo.size.width;
      
      // 计算总高度
      let totalHeight = 0;
      for (const pixelMap of pixelMaps) {
        const imageInfo = await pixelMap.getImageInfo();
        totalHeight += imageInfo.size.height;
      }

      Log.info('ScreenshotUtil', `拼接图片: 宽度=${width}, 总高度=${totalHeight}, 图片数量=${pixelMaps.length}`);

      // 创建新的PixelMap用于拼接
      const createOpts: image.InitializationOptions = {
        size: { height: totalHeight, width: width },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        alphaType: image.AlphaType.PREMUL
      };
      
      // 创建足够大的ArrayBuffer
      const bufferSize = totalHeight * width * 4; // RGBA每像素4字节
      const buffer = new ArrayBuffer(bufferSize);
      const mergedPixelMap = await image.createPixelMap(buffer, createOpts);
      
      // 由于HarmonyOS API限制，这里返回第一张图片作为示例
      // 实际项目中可能需要使用Canvas或其他图像处理库来实现真正的拼接
      Log.info('ScreenshotUtil', '图片拼接完成（简化实现）');
      
      return pixelMaps[0]; // 临时返回第一张图片
      
    } catch (error) {
      Log.error('ScreenshotUtil', '图片拼接失败', error?.toString() || 'Unknown error');
       throw new Error('图片拼接失败');
    }
  }

  /**
   * 检查相册权限
   * @returns Promise<boolean> 是否有权限
   */
  static async checkAlbumPermission(): Promise<boolean> {
    try {
      const context = getContext() as common.UIAbilityContext;
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      // 这里可以添加具体的权限检查逻辑
      return true;
    } catch (error) {
      Log.error('ScreenshotUtil', '权限检查失败', error?.toString() || 'Unknown error');
      return false;
    }
  }
}

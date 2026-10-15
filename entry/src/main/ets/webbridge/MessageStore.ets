import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 留言数据模型
 */
export interface Message {
  id: number;
  nickname: string;
  content: string;
  timestamp: number;
}

/**
 * MessageStore —— 留言持久化层
 * 基于 Preferences 键值存储，将留言数组序列化为 JSON 字符串保存。
 * 职责单一：只负责数据的增删查，不关心 Web / UI 细节。
 */
export class MessageStore {
  private static readonly STORE_NAME: string = 'message_store';
  private static readonly KEY_MESSAGES: string = 'messages';
  private pref: preferences.Preferences | null = null;

  /** 必须在页面 aboutToAppear 时调用，传入 AbilityContext */
  init(context: common.Context): void {
    if (!this.pref) {
      this.pref = preferences.getPreferencesSync(context, { name: MessageStore.STORE_NAME });
    }
  }

  /** 读取全部留言（按时间正序） */
  getAll(): Message[] {
    if (!this.pref) {
      return [];
    }
    const raw = this.pref.getSync(MessageStore.KEY_MESSAGES, '[]') as string;
    try {
      return JSON.parse(raw) as Message[];
    } catch (e) {
      return [];
    }
  }

  /** 新增一条留言，返回保存后的对象 */
  add(nickname: string, content: string): Message {
    const list = this.getAll();
    const msg: Message = {
      id: Date.now(),
      nickname: nickname,
      content: content,
      timestamp: Date.now()
    };
    list.push(msg);
    this.persist(list);
    return msg;
  }

  /** 清空所有留言 */
  clear(): void {
    this.persist([]);
  }

  private persist(list: Message[]): void {
    if (!this.pref) {
      return;
    }
    this.pref.putSync(MessageStore.KEY_MESSAGES, JSON.stringify(list));
    this.pref.flush();
  }
}

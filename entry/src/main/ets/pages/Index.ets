import { bundleManager, common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { demoVersionCode, eligibleForPrompt, storeLink } from './UpdatePolicy';

const RELEASE_API = 'https://api.github.com/repos/thx853068675-dev/QSStore-Update-Demo/releases/latest';

interface DemoRelease {
  tag_name: string;
  published_at: string;
  draft: boolean;
  prerelease: boolean;
}

@Entry
@Component
struct Index {
  @State private link: string = '';
  @State private installedVersion: string = '';
  @State private installedCode: number = 0;
  @State private feedback: string = '';
  @State private checking: boolean = false;
  private promptedCode: number = 0;
  private visible: boolean = false;

  aboutToAppear(): void {
    this.visible = true;
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT).then(info => {
      if (!this.visible) return;
      this.installedVersion = info.versionName;
      this.installedCode = info.versionCode;
    }).catch(() => {});
  }

  aboutToDisappear(): void { this.visible = false; }

  private async connectInstaller(target: string): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    try {
      await context.openLink(target, { appLinkingOnly: false });
    } catch (_) {
      if (this.visible) this.feedback = '未能打开轻启·安装器，请确认安装器已安装。';
    }
  }

  private async confirm(target: string, title: string, detail: string): Promise<void> {
    try {
      const response = await promptAction.showDialog({
        title, message: detail,
        buttons: [{ text: '稍后', color: '#566474' }, { text: '去安装器更新', color: '#08746A' }]
      });
      if (response.index === 1 && this.visible) await this.connectInstaller(target);
    } catch (_) { /* Closing the dialog leaves the Demo in front. */ }
  }

  private simulate(): void {
    const target = storeLink(this.link);
    if (!target) {
      this.feedback = '请粘贴从安装器复制的正式版更新链接。';
      return;
    }
    this.confirm(target, '测试更新弹窗', '验证跳转到链接对应的安装器详情页。');
  }

  private async checkRelease(): Promise<void> {
    if (this.checking || this.installedCode <= 0) return;
    const target = storeLink(this.link);
    if (!target) {
      this.feedback = '请先粘贴此 Demo 的正式版更新链接。';
      return;
    }
    this.checking = true;
    this.feedback = '';
    const request = http.createHttp();
    try {
      const response = await request.request(RELEASE_API, {
        method: http.RequestMethod.GET,
        header: { 'Accept': 'application/vnd.github+json' },
        connectTimeout: 5000, readTimeout: 5000, expectDataType: http.HttpDataType.STRING
      });
      if (!this.visible) return;
      if (response.responseCode !== 200 || typeof response.result !== 'string') {
        this.feedback = '暂时无法检查版本，请稍后重试。';
        return;
      }
      const release = JSON.parse(response.result) as DemoRelease;
      const code = demoVersionCode(release.tag_name || '');
      if (release.draft || release.prerelease || code <= this.installedCode) {
        this.feedback = '当前已是最新正式版。';
        return;
      }
      if (!eligibleForPrompt(this.installedCode, code, Date.parse(release.published_at), Date.now())) {
        this.feedback = '新版本正在等待商店同步，发布满一小时后提醒。';
        return;
      }
      if (this.promptedCode === code) {
        this.feedback = '本次已经提醒过该版本。';
        return;
      }
      this.promptedCode = code;
      await this.confirm(target, '发现新版本 ' + release.tag_name.substring(1), '在轻启·安装器查看更新并安装。');
    } catch (_) {
      if (this.visible) this.feedback = '暂时无法检查版本，请稍后重试。';
    } finally {
      request.destroy();
      if (this.visible) this.checking = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 9 }) {
          Text('更新接入 Demo').fontSize(29).fontWeight(FontWeight.Bold).fontColor('#F3FCF9')
          if (this.installedVersion) {
            Text('已安装 ' + this.installedVersion).fontSize(14).fontColor('#A2D8CD').id('demo-installed-version')
          }
        }.width('100%').alignItems(HorizontalAlign.Start).padding({ left: 2, top: 24, bottom: 8 })
        Column({ space: 12 }) {
          Text('轻启更新链接').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#152C31').width('100%')
          TextInput({ text: this.link, placeholder: '粘贴 qingqi-installer://app/…' })
            .id('demo-link').height(48).fontSize(13).backgroundColor('#E7F2EE')
            .onChange((value: string) => this.link = value)
          Button(this.checking ? '检查中…' : '检查更新', { type: ButtonType.Capsule })
            .id('demo-check').width('100%').height(48).fontSize(15).backgroundColor('#0A776D')
            .enabled(!this.checking && this.installedCode > 0).onClick(() => this.checkRelease())
          Button('测试更新弹窗', { type: ButtonType.Capsule })
            .id('demo-simulate').width('100%').height(46).fontSize(14).fontColor('#09685D')
            .backgroundColor('#DEF0EA').onClick(() => this.simulate())
          if (this.feedback) {
            Text(this.feedback).fontSize(13).fontColor('#40585D').width('100%').id('demo-feedback')
          }
        }.width('100%').padding(18).borderRadius(24).backgroundColor('#F5FAF7')
      }.width('100%').constraintSize({ maxWidth: 480 }).padding(24)
    }.width('100%').height('100%').backgroundColor('#111D2B').scrollBar(BarState.Off)
  }
}

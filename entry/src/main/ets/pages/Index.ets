import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

const STORE_UPDATE_LINK: string = 'qingqi-installer://app/407?preview=0';

@Entry
@Component
struct Index {
  @State private dialogOpen: boolean = false;
  @State private feedback: string = '';

  private async showUpdate(): Promise<void> {
    if (this.dialogOpen) return;
    this.dialogOpen = true;
    this.feedback = '';
    try {
      const answer = await promptAction.showDialog({
        title: '发现新版本',
        message: '前往轻启·安装器查看更新。',
        buttons: [
          { text: '稍后', color: '#526473' },
          { text: '去安装器更新', color: '#07695F' }
        ]
      });
      if (answer.index === 1) {
        const context = getContext(this) as common.UIAbilityContext;
        await context.openLink(STORE_UPDATE_LINK, { appLinkingOnly: false });
      }
    } catch (_) {
      this.feedback = '无法打开轻启·安装器，请确认安装器已安装。';
    } finally {
      this.dialogOpen = false;
    }
  }

  build() {
    Column() {
      Column({ space: 18 }) {
        Text('更新接入 Demo').fontSize(29).fontWeight(FontWeight.Bold)
          .fontColor('#F3FCF9').width('100%')
        Column({ space: 14 }) {
          Text('轻启·安装器').fontSize(17).fontWeight(FontWeight.Medium)
            .fontColor('#153430').width('100%')
          Text(STORE_UPDATE_LINK).fontSize(13).fontColor('#385952').width('100%')
            .id('demo-update-link')
          Button('测试更新弹窗', { type: ButtonType.Capsule }).height(48).width('100%')
            .backgroundColor('#08756B').fontColor('#FFFFFF').fontSize(15)
            .id('demo-simulate').enabled(!this.dialogOpen).onClick(() => this.showUpdate())
          if (this.feedback) {
            Text(this.feedback).fontSize(13).fontColor('#40585D').width('100%').id('demo-feedback')
          }
        }.padding(18).borderRadius(24).backgroundColor('#F5FAF7').width('100%')
      }.padding(24).constraintSize({ maxWidth: 480 }).width('100%')
    }.height('100%').width('100%').backgroundColor('#111D2B').justifyContent(FlexAlign.Center)
  }
}

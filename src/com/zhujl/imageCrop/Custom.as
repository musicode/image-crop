/**
 * @file 自定义部分
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Sprite;
    import flash.display.Graphics;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextFieldAutoSize;

    import fl.controls.Button;

    public class Custom {

        private static var tf: TextFormat = new TextFormat('宋体', 13, 0x555555);

        public static function getSrcWelcome(width: Number, height: Number): Sprite {

            var bg: Sprite = new Sprite();

            var graphics: Graphics = bg.graphics;

            // 画边框
            graphics.beginFill(0xD8D8D8);
            graphics.drawRect(0, 0, width, height);

            // 画填充色
            graphics.beginFill(0xF1F1F1);
            graphics.drawRect(1, 1, width - 2, height - 2);

            graphics.endFill();

            return bg;
        }

        public static function getSrcBackground(width: Number, height: Number): Sprite {
            return getSrcWelcome(width, height);
        }

        public static function getSelectButton(): Button {
            var btn: Button = new Button();
            btn.label = '选择';
            btn.useHandCursor = true;
            btn.setStyle('textFormat', Custom.tf);
            return btn;
        }

        public static function getUploadButton(): Button {
            var btn: Button = new Button();
            btn.label = '上传';
            btn.useHandCursor = true;
            btn.setStyle('textFormat', Custom.tf);
            return btn;
        }

        public static function getDownloadButton(): Button {
            var btn: Button = new Button();
            btn.label = '保存';
            btn.useHandCursor = true;
            btn.setStyle('textFormat', Custom.tf);
            return btn;
        }

        public static function getLeftRotateButton(): Button {
            var btn: Button = new Button();
            btn.label = '左转';
            btn.useHandCursor = true;
            btn.setStyle('textFormat', Custom.tf);
            return btn;
        }

        public static function getRightRotateButton(): Button {
            var btn: Button = new Button();
            btn.label = '右转';
            btn.useHandCursor = true;
            btn.setStyle('textFormat', Custom.tf);
            return btn;
        }

        public static function drawCropAlphaMask(alphaMask: Sprite,
                                                width: Number,
                                                height: Number): void {
            var graphics: Graphics = alphaMask.graphics;
            graphics.clear();
            graphics.beginFill(0x000000, 0.3);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        public static function drawCropImageMask(imageMask: Sprite,
                                                width: Number,
                                                height: Number): void {
            var graphics: Graphics = imageMask.graphics;
            graphics.clear();
            // 这里的颜色不重要, 只要有颜色就行...
            graphics.beginFill(0xFF0000, 1);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        public static function getCropResizer(): Sprite {

            var width: Number = 8;
            var height: Number = 8;
            var borderWidth: Number = 1;

            var resizer: Sprite = new Sprite();
            var graphics: Graphics = resizer.graphics;

            graphics.beginFill(0x000000, 0.3);
            graphics.lineStyle(borderWidth, 0xFFFFFF);
            graphics.drawRect(
                -1 * width / 2 + borderWidth,
                -1 * height / 2 + borderWidth,
                width - 2 * borderWidth,
                height - 2 * borderWidth
            );
            graphics.endFill();

            return resizer;
        }

        public static function getDestBackground(width: Number, height: Number): Sprite {

            var bg: Sprite = new Sprite();

            var graphics: Graphics = bg.graphics;

            // 画边框
            graphics.beginFill(0xD8D8D8);
            graphics.drawRect(0, 0, width, height);

            // 画填充色
            graphics.beginFill(0xF1F1F1);
            graphics.drawRect(1, 1, width - 2, height - 2);

            graphics.endFill();

            var tf: TextFormat = new TextFormat();
            tf.font = '宋体';
            tf.size = 13;
            tf.color = 0x666666;
            tf.align = TextFormatAlign.CENTER;

            var textField: TextField = new TextField();
            textField.selectable = false;
            textField.wordWrap = true;
            textField.autoSize = TextFieldAutoSize.CENTER;

            textField.defaultTextFormat = tf;
            textField.text = '暂无预览';
            textField.x = (width - textField.width) / 2;
            textField.y = (height - textField.height) / 2;

            bg.addChild(textField);

            return bg;
        }

        public static function getDestText(text: String): TextField {

            var tf: TextFormat = new TextFormat();
            tf.font = '宋体';
            tf.size = 13;
            tf.color = 0x666666;
            tf.align = TextFormatAlign.CENTER;

            var textField: TextField = new TextField();
            textField.selectable = false;
            textField.wordWrap = true;
            textField.autoSize = TextFieldAutoSize.CENTER;

            textField.defaultTextFormat = tf;
            textField.text = text;

            return textField;
        }

    }
}
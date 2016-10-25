/**
 * @file 预览图
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    import flash.text.TextField;

    public class Dest extends Sprite {

        /**
         * 预览图
         *
         * @type {Image}
         */
        public var image: Image;

        private var destRadius: Number;
        private var destWidth: Number;
        private var destHeight: Number;
        private var destText: String;

        /**
         * 创建预览图
         */
        public function Dest(destRadius: Number,
                            destWidth: Number,
                            destHeight: Number,
                            destText: String = '') {

            this.destRadius = destRadius;
            this.destText = destText;

            if (destRadius) {
                this.destWidth =
                this.destHeight = destRadius * 2;
            }
            else {
                this.destWidth = destWidth;
                this.destHeight = destHeight;
            }

            addBackground();
            addImage();

            if (destText) {
                addText();
            }
        }

        /**
         * 添加背景
         */
        public function addBackground(): void {
            this.addChild(
                Custom.getDestBackground(
                    destRadius + 1,
                    destWidth + 2,
                    destHeight + 2
                )
            );
        }

        /**
         * 添加预览图
         */
        private function addImage(): void {

            image = new Image(
                        new Bitmap(
                            new BitmapData(
                                destWidth,
                                destHeight,
                                true,
                                0
                            )
                        ),
                        'jpg'
                    );

            image.x = 1;
            image.y = 1;

            if (destRadius) {
                var mask: Shape = Custom.getCircle(destRadius);
                mask.x =
                mask.y = destRadius + 1;
                this.addChild(mask);
                image.mask = mask;
            }

            this.addChild(image);

        }

        /**
         * 添加图片分辨率的说明文字
         */
        private function addText(): void {

            var textField: TextField = Custom.getDestText(destText);
            textField.x = 0;
            textField.y = image.y + image.height + 5;
            textField.width = image.width;

            this.addChild(textField);
        }
    }
}
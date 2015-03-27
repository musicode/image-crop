/**
 * @file 图片裁剪器. 盖住图片的遮罩 + 裁剪窗口
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Sprite;
    import flash.display.BitmapData;

    import flash.geom.Rectangle;

    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * 裁剪器分 5 层, 从底层到顶层依次如下:
     *
     * 图片
     * 半透明遮罩
     * 图片的副本
     * 图片遮罩(取景窗口)
     * resizer
     *
     * 拖动顶层的图片遮罩即可改变取景
     */
    public class Crop extends Sprite {

        private var cropWidth: Number;
        private var cropHeight: Number;

        private var ratio: Number;

        /**
         * 图片被缩放的比例
         *
         * @type {Number}
         */
        private var scale: Number;

        /**
         * 需要裁剪的图片
         *
         * @type {Image}
         */
        public var image: Image;

        /**
         * 半透明遮罩
         */
        public var alphaMask: Sprite;

        /**
         * 图片副本
         *
         * @type {Image}
         */
        public var imageCopy: Image;

        /**
         * 图片遮罩
         */
        public var imageMask: Sprite;

        /**
         * 拖动改变 imageMask 大小的 handler
         */
        private var resizer: Sprite;

        /**
         * 这两个属性用来辅助计算
         */
        private var offsetX: Number;
        private var offsetY: Number;

        private var resizeBounds: Rectangle = new Rectangle();

        public function Crop(cropWidth: Number, cropHeight: Number) {

            this.cropWidth = cropWidth;
            this.cropHeight = cropHeight;
            this.ratio = cropWidth / cropHeight;

            addAlphaMask();
            addImageMask();
            addResizer();
        }

        /**
         * 添加半透明遮罩
         */
        private function addAlphaMask(): void {
            alphaMask = new Sprite();
            this.addChild(alphaMask);
        }

        /**
         * 添加图片遮罩
         */
        private function addImageMask(): void {

            imageMask = new Sprite();
            this.addChild(imageMask);

            // 遮罩无法响应事件, 所以改变机制
            // 用坐标判断是否点在遮罩内
            this.addEventListener(MouseEvent.MOUSE_DOWN, startDragImageMask);
        }

        /**
         * 添加裁剪窗口右下角的可拖动对象
         */
        private function addResizer(): void {

            resizer = Custom.getCropResizer();
            this.addChild(resizer);

            resizer.addEventListener(MouseEvent.MOUSE_DOWN, startDragResizer);
        }

        /**
         * 设置裁剪的图片
         *
         * @param {Image} image 需要裁剪的图片
         */
        public function setImage(image: Image, scale: Number): void {

            if (this.image && this.contains(this.image)) {
                this.removeChild(this.image);
            }

            if (this.imageCopy && this.contains(this.imageCopy)) {
                this.removeChild(this.imageCopy);
            }

            image.x = 0;
            image.y = 0;

            this.image = image;

            // 原始图片放在第一层
            this.addChildAt(image, 0);

            // 图片副本放在第三层
            imageCopy = image.clone();
            imageCopy.mask = imageMask;
            this.addChildAt(imageCopy, 2);

            // 更新半透明遮罩
            Custom.drawCropAlphaMask(
                alphaMask,
                image.width,
                image.height
            );

            this.scale = scale;

            var scale: Number = 1;
            if (cropWidth > image.width || cropHeight > image.height) {
                scale = Util.getScale(
                            {
                                width: cropWidth,
                                height: cropHeight
                            },
                            {
                                width: image.width,
                                height: image.height
                            }
                        );
            }

            resizeImageMask(
                cropWidth * scale,
                cropHeight * scale
            );

            // 居中
            moveImageMask(
                (image.width - imageMask.width) / 2,
                (image.height - imageMask.height) / 2
            );
        }

        /**
         * 调整图片遮罩的大小
         *
         * @param {Number} width
         * @param {Number} height
         */
        private function resizeImageMask(width: Number, height: Number): void {

            Custom.drawCropImageMask(
                imageMask,
                width,
                height
            );

            this.dispatchEvent(
                new Event(Event.CHANGE)
            );
        }

        /**
         * 移动图片遮罩
         *
         * @param {Number} x
         * @param {Number} y
         */
        private function moveImageMask(x: Number, y: Number): void {

            imageMask.x = x;
            imageMask.y = y;

            resizer.x = x + imageMask.width;
            resizer.y = y + imageMask.height;

            this.dispatchEvent(
                new Event(Event.CHANGE)
            );
        }

        /**
         * 获得裁剪区域
         *
         * @return {Rectangle}
         */
        public function getCropRectangle(): Rectangle {

            var reverse: Number = 1 / scale;

            return new Rectangle(
                imageMask.x * reverse,
                imageMask.y * reverse,
                imageMask.width * reverse,
                imageMask.height * reverse
            );
        }


        private function startDragImageMask(e: MouseEvent): void {

            var imageMaskBound: Object = {
                top: imageMask.y,
                right: imageMask.x + imageMask.width,
                bottom: imageMask.y + imageMask.height,
                left: image.x
            };

            if (e.localX >= imageMaskBound.left
                && e.localY >= imageMaskBound.top
                && e.localX <= imageMaskBound.right
                && e.localY <= imageMaskBound.bottom
            ) {

                // 不能点在 resizer 上
                if (e.localX < resizer.x || e.localY < resizer.y) {
                    offsetX = imageMask.mouseX;
                    offsetY = imageMask.mouseY;

                    stage.addEventListener(MouseEvent.MOUSE_MOVE, draggingImageMask);
                    stage.addEventListener(MouseEvent.MOUSE_UP, stopDragImageMask);
                }
            }

        }

        private function draggingImageMask(e: MouseEvent): void {

            var x: Number = Util.bound(
                                this.mouseX - offsetX,
                                0,
                                image.width - imageMask.width
                            );

            var y: Number = Util.bound(
                                this.mouseY - offsetY,
                                0,
                                image.height - imageMask.height
                            );

            moveImageMask(x, y);
        }

        private function stopDragImageMask(e: MouseEvent): void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggingImageMask);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragImageMask);
        }

        private function startDragResizer(e: MouseEvent): void {
            offsetX = resizer.mouseX;
            offsetY = resizer.mouseY;

            stage.addEventListener(MouseEvent.MOUSE_MOVE, draggingResizer);
            stage.addEventListener(MouseEvent.MOUSE_UP, stopDragResizer);
        }

        private function draggingResizer(e: MouseEvent): void {

            var size: Object = {
                width: this.mouseX - imageMask.x,
                height: this.mouseY - imageMask.y
            };

            var minSize: Object = {
                width: 5,
                height: 5
            };

            if (size.width <= minSize.width || size.height <= minSize.height) {
                return;
            }

            size = Util.getSize(
                ratio,
                size,
                minSize,
                {
                    width: image.width - imageMask.x,
                    height: image.height - imageMask.y
                }
            );

            resizeImageMask(size.width, size.height);
            moveImageMask(imageMask.x, imageMask.y);
        }

        private function stopDragResizer(e: MouseEvent): void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, draggingResizer);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragResizer);
        }

    }
}

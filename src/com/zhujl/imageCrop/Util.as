/**
 * @file 工具方法
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;

    import flash.events.Event;

    import flash.net.FileReference;

    public class Util {

        /**
         * 获得 target 相对于 container 的缩放值
         *
         * target 和 container 包含 width height
         *
         * @param  {Object} target 需要缩放的对象
         * @param  {Object} container 容器对象
         * @return {Number}
         */
        public static function getScale(target: Object, container: Object): Number {

            var scale: Number;

            // 记录初始值
            var width: Number = target.width;
            var height: Number = target.height;

            scale = container.width / width;
            width = container.width;
            height *= scale;

            if (height > container.height) {
                scale = container.height / height;
                height = container.height;
                width *= scale;
            }

            return width / target.width;
        }

        /**
         * 获得合法的等比例的尺寸
         */
        public static function getSize(ratio: Number, target: Object, min: Object, max: Object): Object {

            // 先约束比例
            target = Util.fitRatio(target, ratio);

            var w: Number = target.width / min.width;
            var h: Number = target.height / min.height;

            if (w < 0 || h < 0) {
                if (w < h) {
                    w = min.width;
                    h = w / ratio;
                }
                else {
                    h = min.height;
                    w = h * ratio;
                }

                return {
                    width: w,
                    height: h
                };
            }

            w = target.width / max.width;
            h = target.height / max.height;

            if (w > 1 || h > 1) {
                if (w > h) {
                    w = max.width;
                    h = w / ratio;
                }
                else {
                    h = max.height;
                    w = h * ratio;
                }
                return {
                    width: w,
                    height: h
                };
            }

            return target;
        }

        public static function fitRatio(target: Object, ratio: Number): Object {
            if (target.width / target.height !== ratio) {
                if (target.width > target.height) {
                    target.width = target.height * ratio;
                }
                else {
                    target.height = target.width / ratio;
                }
            }
            return target;
        }

        /**
         * 获得 [minValue, maxValue] 区间内的合法值
         *
         * @param {Number} value
         * @param {Number} minValue
         * @param {Number} maxValue
         * @return {Number}
         */
        public static function bound(value: Number, minValue: Number, maxValue: Number): Number {
            if (value > maxValue) {
                return maxValue;
            }
            else if (value < minValue) {
                return minValue;
            }
            return value;
        }

        /**
         * 获得文件扩展名（FileReference.type 在 Mac 下有问题，最好别用）
         *
         * @param {String} filename
         * @return {String}
         */
        public static function getFileType(file: FileReference): String {
            var type: String = file.type;
            if (type) {
                if (type.charAt(0) === '.') {
                    type = type.substr(1);
                }
            }
            else {
                var index: Number = file.name.lastIndexOf('.');
                if (index >= 0) {
                    type = file.name.substr(index + 1);
                }
            }
            return type ? type.toLowerCase() : '';
        }

    }
}

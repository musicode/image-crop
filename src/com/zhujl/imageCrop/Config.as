/**
 * @file 配置文件
 * @author zhujl
 */
package com.zhujl.imageCrop {

    public class Config {

        public static var encoder: String;
        public static var action: String;
        public static var header: Object;

        public static var button: Object;
        public static var src: Object;
        public static var dest: Array;

        public static var accept: Array;
        public static var adaptive: Boolean;
        public static var original: Boolean;

        public static var minSize: Number;
        public static var maxSize: Number;
        public static var minWidth: Number;
        public static var maxWidth: Number;
        public static var minHeight: Number;
        public static var maxHeight: Number;

        /**
         * 初始化配置
         *
         * @param {Object} options 外部传入的配置
         * @param {String} options.action 上传地址
         * @param {String} options.encoder 编码格式 png 或 jpg
         * @param {?String} options.accept 可接受的图片格式, 以 , 分隔
         * @param {?String} options.header 上传时一起发送的头信息，格式是 json 字符串
         * @param {?Boolean} options.adaptive 是否自适应为图片允许的最大的尺寸
         * @param {?Boolean} options.original 是否原图上传
         * @param {?Number} options.minSize 最小大小，单位是 kb
         * @param {?Number} options.maxSize 最大大小，单位是 kb
         * @param {?Number} options.minWidth 最小宽度，单位是 px
         * @param {?Number} options.maxWidth 最大宽度，单位是 px
         * @param {?Number} options.minHeight 最小高度，单位是 px
         * @param {?Number} options.maxHeight 最大高度，单位是 px
         * @param {String} options.button 按钮配置，格式是 json 字符串
         * @param {String} options.src 源图片配置，格式是 json 字符串
         * @param {String} options.dest 输出图片配置，格式是 json 字符串
         */
        public static function init(options: Object): void {

            Config.action = options.action;
            Config.encoder = options.encoder === 'png' ? 'png' : 'jpg';

            if (options.minSize) {
                Config.minSize = Number(options.minSize);
            }
            if (options.maxSize) {
                Config.maxSize = Number(options.maxSize);
            }
            if (options.minWidth) {
                Config.minWidth = Number(options.minWidth);
            }
            if (options.maxWidth) {
                Config.maxWidth = Number(options.maxWidth);
            }
            if (options.minHeight) {
                Config.minHeight = Number(options.minHeight);
            }
            if (options.maxHeight) {
                Config.maxHeight = Number(options.maxHeight);
            }

            if (options.src) {
                Config.src = typeof options.src === 'string'
                           ? JSON.parse(options.src)
                           : options.src;
            }

            if (options.dest) {
                Config.dest = typeof options.dest === 'string'
                            ? (JSON.parse(options.dest) as Array)
                            : options.dest;
            }

            if (options.button) {
                Config.button = typeof options.button === 'string'
                              ? JSON.parse(options.button)
                              : options.button;
            }

            if (options.accept) {
                Config.accept = typeof options.accept === 'string'
                              ? options.accept.split(',')
                              : options.accept;
            }

            if (options.header) {
                Config.header = typeof options.header === 'string'
                              ? JSON.parse(options.header)
                              : options.header;
            }

            if (options.adaptive) {
                Config.adaptive = typeof options.adaptive === 'string'
                              ? options.adaptive === 'true'
                              : false;
            }

            if (options.original) {
                Config.original = typeof options.original === 'string'
                              ? options.original === 'true'
                              : false;
            }

        }
    }
}

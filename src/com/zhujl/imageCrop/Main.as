/**
 * @file 图片裁剪工具主程序
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import fl.controls.Button;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;

    import flash.geom.Rectangle;
    import flash.geom.Point;

    import flash.system.Security;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.events.HTTPStatusEvent;

    /**
     * 配置
     *
     * {
     *     movieName: 'swf 实例 id',
     *     action: '上传地址',
     *     accept: '可接受的图片格式, 以 , 分隔',
     *     adaptive: true,  // 是否自适应
     *     header: {
     *         key: 'value'
     *     },
     *     button: {
     *         select: { x: 0, y: 0, width: 60 },
     *         upload: { x: 100, y: 0 },
     *         download: { x: 100, y: 0 },
     *         leftRotate: { x: 150, y: 0 }
     *         rightRotate: { x: 200, y: 0 }
     *     },
     *     src: { x: 0, y: 0, width: 100, height: 100 },
     *     dest: [
     *         { x: 100, y: 100, with: 360, height: 240, text: '360x240' },
     *         { x: 100, y: 100, with: 480, height: 360, text: '480x360' }
     *     ]
     * }
     */
    public class Main extends MovieClip {

        private var selectButton: Button;
        private var uploadButton: Button;
        private var downloadButton: Button;
        private var leftRotateButton: Button;
        private var rightRotateButton: Button;

        /**
         * 文件选择窗口
         */
        private var imageBrowser: ImageBrowser;

        /**
         * 外部通信接口
         */
        private var externalCall: ExternalCall;

        /**
         * 取景中心点坐标
         */
        private var center: Point;

        /**
         * 选择的原始图片
         */
        private var srcImage: Image;

        /**
         * 未选择图片时的欢迎图
         */
        private var srcWelcome: Sprite;

        /**
         * 选择图片时的背景
         */
        private var srcBackground: Sprite;

        /**
         * 输出图片
         */
        private var destImages: Array;

        /**
         * 最终处理的图片
         */
        private var finalImage: Image;

        /**
         * 裁剪器, 包括遮罩和修剪框
         */
        private var crop: Crop;

        public function Main() {

            initStage();
            initExternal();

            if (Config.button
                && Config.src
                && Config.dest
            ) {
                initUI();
            }

        }

        /**
         * 初始化舞台, 包括跨域设置, 缩放对齐
         */
        public function initStage(): void {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }

        /**
         * 初始化配置对象, 设置通信接口
         */
        public function initExternal(): void {

            // 页面传入的参数
            var params: Object = stage.loaderInfo.parameters;
/**
            var params = {
                movieName: 'asdasd',
                action: 'http://xxx.com',
                header: {
                    'xxx': 'yyyy'
                },
                accept: 'png,jpg,jpeg',
                minSize: 1,
                maxSize: 1024,
                //adaptive: 'true',

                button: {
                    select: {
                        x: 95,
                        y: 290,
                        width: 100,
                        height: 50,
                        text: '选择照片'
                    },
                    download: {
                        x: 250,
                        y: 125,
                        width: 100,
                        height: 50,
                        text: '另存为'
                    }
                },

                src: {
                    x: 0,
                    y: 0,
                    width: 275,
                    height: 275
                },

                dest: [
                    {
                        x: 330,
                        y: 0,
                        width: 110,
                        height: 100,
                        text: '大尺寸头像\n（自动生成）'
                    },
                    {
                        x: 330,
                        y: 165,
                        width: 90,
                        height: 90,
                        text: '小尺寸头像（自动生成)'
                    }
                ]
            };
*/
            // 根据参数初始化配置对象
            Config.init(params);

            externalCall = new ExternalCall(params.movieName);
            externalCall.addCallback('upload', upload);
            externalCall.addCallback('download', download);
            externalCall.addCallback('leftRotate', leftRotate);
            externalCall.addCallback('rightRotate', rightRotate);
            externalCall.addCallback('isReady', isReady);
        }

        /**
         * 初始化界面
         */
        public function initUI(): void {

            var srcConfig: Object = Config.src;

            srcWelcome = Custom.getSrcWelcome(srcConfig.width, srcConfig.height);
            srcWelcome.x = srcConfig.x;
            srcWelcome.y = srcConfig.y;
            addChild(srcWelcome);

            // 获取画布中心的坐标, 便于进行旋转
            center = new Point(
                        srcConfig.x + srcConfig.width / 2,
                        srcConfig.y + srcConfig.height / 2
                    );

            addDest();

            selectButton = addButton('select');
            if (selectButton) {
                selectButton.addEventListener(MouseEvent.CLICK, clickSelectButton);
            }

            uploadButton = addButton('upload');
            if (uploadButton) {
                uploadButton.enabled = false;
                uploadButton.addEventListener(MouseEvent.CLICK, onUpload);
            }

            downloadButton = addButton('download');
            if (downloadButton) {
                downloadButton.enabled = false;
                downloadButton.addEventListener(MouseEvent.CLICK, onDownload);
            }

            leftRotateButton = addButton('leftRotate');
            if (leftRotateButton) {
                leftRotateButton.enabled = false;
                leftRotateButton.addEventListener(MouseEvent.CLICK, onLeftRotate);
            }

            rightRotateButton = addButton('rightRotate');
            if (rightRotateButton) {
                rightRotateButton.enabled = false;
                rightRotateButton.addEventListener(MouseEvent.CLICK, onRightRotate);
            }

            imageBrowser = new ImageBrowser();
            imageBrowser.addEventListener(ImageEvent.ACCEPT_ERROR, imageAcceptError);
            imageBrowser.addEventListener(ImageEvent.SIZE_ERROR, imageSizeError);
            imageBrowser.addEventListener(ImageEvent.DIMENSION_ERROR, imageDimensionError);
            imageBrowser.addEventListener(ImageEvent.LOAD_COMPLETE, imageLoadComplete);

            // 通知页面加载完成
            externalCall.loaded();
        }

        /**
         * 添加按钮
         *
         * @param {String} name 按钮名称，只包含四种：select upload leftRotate rightRotate
         */
        private function addButton(name: String): Button {

            var buttonConfig: Object = Config.button;
            var config: Object = buttonConfig[name];

            if (config) {

                var getter: String = 'get' + name.substr(0, 1).toUpperCase() + name.substr(1) + 'Button';

                var btn: Button = Custom[getter]();
                btn.x = config.x;
                btn.y = config.y;

                if (config.text) {
                    btn.label = config.text;
                }
                if (config.width) {
                    btn.width = config.width;
                }
                if (config.height) {
                    btn.height = config.height;
                }

                addChild(btn);

                return btn;
            }

            return null;
        }

        /**
         * 初始化图片预览
         */
        private function addDest(): void {

            destImages = new Array();

            var maxSize: Number = 0;
            var me: MovieClip = this;

            Config.dest.forEach(
                function (item: Object, index: Number, array: Array) {

                    var dest: Dest = new Dest(item.width, item.height, item.text);
                    dest.x = item.x;
                    dest.y = item.y;
                    me.addChild(dest);

                    var img: Image = dest.image;
                    destImages.push(img);

                    var size: Number = item.width * item.height;
                    if (maxSize === 0 || size > maxSize) {
                        maxSize = size;
                        finalImage = img;
                    }
                }
            );
        }

        public function upload(): void {
            finalImage.addEventListener(Event.OPEN, uploadStartHandler);
            finalImage.addEventListener(ProgressEvent.PROGRESS, uploadingHandler);
            finalImage.addEventListener(IOErrorEvent.IO_ERROR, uploadErrorHandler);
            finalImage.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadStatusHandler);
            finalImage.addEventListener(ImageEvent.UPLOAD_COMPLETE, uploadCompleteHandler);

            finalImage.upload(Config.action, Config.header);
        }

        public function download(): void {
            finalImage.download();
        }

        public function leftRotate(): void {
            srcImage.rotate(-90);
            refreshSrc();
        }

        public function rightRotate(): void {
            srcImage.rotate(90);
            refreshSrc();
        }

        public function isReady(): Boolean {
            return contains(crop);
        }

        /**
         * 刷新裁剪区域
         */
        private function refreshSrc(): void {

            var scale: Number = Util.getScale(
                                    srcImage,
                                    {
                                        width: Config.src.width,
                                        height: Config.src.height
                                    }
                                );

            var img: Image = srcImage.clone();
            img.scale(scale, scale);

            crop.x = center.x - img.width / 2;
            crop.y = center.y - img.height / 2;

            crop.setImage(img, scale);

            refreshDest();
        }

        /**
         * 刷新预览区域
         */
        private function refreshDest(): void {

            var data: BitmapData = srcImage.pick(
                                        crop.getCropRectangle()
                                    );

            destImages.forEach(
                function (img: Image, index: int, array: Array): void {
                    img.draw(data);
                }
            );
        }


        // ====================== event handler ========================================

        private function clickSelectButton(e: MouseEvent): void {
            imageBrowser.selectFile();
        }

        private function imageAcceptError(e: ImageEvent): void {
            externalCall.validateError({
                type: 'accept'
            });
        }

        private function imageSizeError(e: ImageEvent): void {
            externalCall.validateError({
                type: 'size'
            });
        }

        private function imageDimensionError(e: ImageEvent): void {
            externalCall.validateError({
                type: 'dimension'
            });
        }

        private function imageLoadComplete(e: ImageEvent): void {

            var image: Bitmap = e.image;
            srcImage = new Image(image);

            if (uploadButton) {
                uploadButton.enabled = true;
            }
            if (downloadButton) {
                downloadButton.enabled = true;
            }
            if (leftRotateButton) {
                leftRotateButton.enabled = true;
            }
            if (rightRotateButton) {
                rightRotateButton.enabled = true;
            }

            if (contains(srcWelcome)) {
                removeChild(srcWelcome);
            }

            if (!srcBackground) {
                var srcConfig: Object = Config.src;
                srcBackground = Custom.getSrcBackground(srcConfig.width, srcConfig.height);
                srcBackground.x = srcConfig.x;
                srcBackground.y = srcConfig.y;
                addChild(srcBackground);
            }

            if (!crop) {

                var width: uint = finalImage.width;
                var height: uint = finalImage.height;

                crop = new Crop(width, height);
                crop.addEventListener(Event.CHANGE, changeCrop);
                addChild(crop);
            }

            refreshSrc();
        }

        private function changeCrop(e: Event): void {
            refreshDest();
        }

        private function onLeftRotate(e: MouseEvent): void {
            leftRotate();
        }

        private function onRightRotate(e: MouseEvent): void {
            rightRotate();
        }

        private function onUpload(e: MouseEvent): void {
            upload();
        }

        private function onDownload(e: MouseEvent): void {
            download();
        }

        private function uploadStartHandler(e: Event): void {
            externalCall.uploadStart();
        }
        private function uploadingHandler(e: ProgressEvent): void {
            externalCall.uploadProgress(e.bytesLoaded, e.bytesTotal);
        }
        private function uploadErrorHandler(e: IOErrorEvent): void {
            externalCall.uploadError(e.text);
        }
        private function uploadStatusHandler(e: HTTPStatusEvent): void {
            externalCall.uploadStatus(e.status);
        }
        private function uploadCompleteHandler(e: ImageEvent): void {

            finalImage.removeEventListener(Event.OPEN, uploadStartHandler);
            finalImage.removeEventListener(ProgressEvent.PROGRESS, uploadingHandler);
            finalImage.removeEventListener(IOErrorEvent.IO_ERROR, uploadErrorHandler);
            finalImage.removeEventListener(HTTPStatusEvent.HTTP_STATUS, uploadStatusHandler);
            finalImage.removeEventListener(ImageEvent.UPLOAD_COMPLETE, uploadCompleteHandler);

            externalCall.uploadComplte(e.data);
        }

    }

}

/**
 * @file 图片选择窗
 * @author zhujl
 */
package com.zhujl.imageCrop {

    import flash.display.Loader;
    import flash.display.LoaderInfo;

    import flash.display.Bitmap;

    import flash.net.FileReference;
    import flash.net.FileFilter;

    import flash.events.Event;
    import flash.events.EventDispatcher;

    public class ImageBrowser extends EventDispatcher  {

        public var file: FileReference;

        /**
         * 打开图片选择窗
         */
        public function selectFile(): void {

            file = new FileReference();
            file.addEventListener(Event.SELECT, selectHandler);

            var accept: Array = Config.accept;
            var temp: Array = new Array();

            accept.forEach(
                function (type: String, index: int, array: Array) {
                    temp.push('*.' + type);
                }
            );

            var fileFilter: FileFilter = new FileFilter(
                                            'Images: (' + temp.join(', ') + ')',
                                            temp.join('; ')
                                        );
            file.browse([fileFilter]);
        }

        /**
         * 验证图片大小
         *
         * @return {Boolean}
         */
        private function validateSize(): Boolean {
            var size: Number = file.size / 1024;
            if (Config.minSize && size < Config.minSize
                || Config.maxSize && size > Config.maxSize
            ) {
                return false;
            }
            return true;
        }

        /**
         * 验证图片类型
         *
         * @return {Boolean}
         */
        private function validateAccept(): Boolean {
            var type: String = Util.getFileType(file);
            return Config.accept.indexOf(type) >= 0;
        }

        /**
         * 验证图片尺寸
         *
         * @return {Boolean}
         */
        private function validateDimension(image: Bitmap): Boolean {
            if (Config.minWidth && image.width < Config.minWidth
                || Config.maxWidth && image.width > Config.maxWidth
                || Config.minHeight && image.height < Config.minHeight
                || Config.maxHeight && image.height < Config.maxHeight
            ) {
                return false;
            }
            return true;
        }


        private function selectHandler(e: Event): void {

            file.removeEventListener(Event.SELECT, selectHandler);

            var event: ImageEvent;

            if (!validateAccept()) {
                event = new ImageEvent(ImageEvent.ACCEPT_ERROR);
            }
            else if (!validateSize()) {
                event = new ImageEvent(ImageEvent.SIZE_ERROR);
            }

            if (event) {
                this.dispatchEvent(event);
                return;
            }

            file.addEventListener(Event.COMPLETE, loadCompleteHandler);
            file.load();
        }

        private function loadCompleteHandler(e: Event): void {

            file.removeEventListener(Event.COMPLETE, loadCompleteHandler);

            var loader: Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
            loader.loadBytes(file.data);
        }

        private function loadBytesHandler(e: Event): void {

            var loaderInfo: LoaderInfo = e.target as LoaderInfo;
            loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);

            var image: Bitmap = loaderInfo.content as Bitmap;

            var event: ImageEvent;

            if (validateDimension(image)) {
                event = new ImageEvent(ImageEvent.LOAD_COMPLETE);
                event.image = image;
            }
            else {
                event = new ImageEvent(ImageEvent.DIMENSION_ERROR);
            }

            this.dispatchEvent(event);
        }
    }
}

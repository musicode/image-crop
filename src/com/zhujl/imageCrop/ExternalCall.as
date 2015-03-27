/**
 * @file 外部接口文件, 方便查看对外暴露的接口
 * @author zhujl
 */
package  com.zhujl.imageCrop {

    import flash.external.ExternalInterface;

    public class ExternalCall {

        private var movieName: String;

        public function ExternalCall(movieName: String) {
            this.movieName = movieName;
        }

        /**
         * swf 加载完成后调用
         */
        public function loaded(): void {
            call('onLoaded');
        }

        public function validateError(data: Object): void {
            call('onValidateError', data);
        }

        /**
         * 图片开始上传时调用
         */
        public function uploadStart(): void {
            call('onUploadStart');
        }

        /**
         * 图片上传过程中调用
         *
         * @param {uint} bytesLoaded
         * @param {uint} bytesTotal
         */
        public function uploadProgress(bytesLoaded: uint, bytesTotal: uint): void {
            call(
                'onUploadProgress',
                {
                    uploaded: bytesLoaded,
                    total: bytesTotal
                }
            );
        }

        /**
         * 图片上传失败后调用
         *
         * @param {String} error 错误信息
         */
        public function uploadError(error: String): void {
            call(
                'onUploadError',
                {
                    error: error
                }
            );
        }

        /**
         * 图片上传过程中调用
         *
         * @param {int} statusCode 状态码
         */
        public function uploadStatus(statusCode: int): void {
            call(
                'onHttpStatus',
                {
                    status: statusCode
                }
            );
        }

        /**
         * 图片上传完成后调用, 不论成功或失败
         *
         * @param {String} data 返回的数据
         */
        public function uploadComplte(data: String): void {
            call(
                'onUploadComplete',
                {
                    data: data
                }
            );
        }

        private function call(name: String, data: Object = null): void {
            var prefix: String = 'ImageCrop.instances["' + movieName + '"].';
            ExternalInterface.call(prefix + name, data);
        }

        public function addCallback(name: String, fn: Function): void {
            ExternalInterface.addCallback(name, fn);
        }

    }
}

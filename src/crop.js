define(function (require, exports) {

    'use strict';

    var Draggable = requie('cobble/helper/Draggable');

    /**
     *
     * @param {Object} options
     * @property {string} options.
     */
    function ImageCrop(options) {
        $.extend(this, options);
        this.init();
    }

    ImageCrop.prototype = {

        constructor: ImageCrop,

        init: function () {

            var me = this;

            me.canvas = canvas.getContext('2d');
            me.crop = new Canvas();
        },

        setImage: function (image) {


        },

        refresh: function () {

            var me = this;

            me.canvas.drawImage(
                me.image,
                sourceX, sourceY, sourceWidth, sourceHeight,
                destX, destY, destWidth, destHeight
            );
        }

    };

    return ImageCrop;

});
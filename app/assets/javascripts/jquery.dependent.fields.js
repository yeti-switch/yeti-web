/**
 * https://github.com/workgena/jQuery-Dependent-Fields
 */
(function($){

    $.fn.dependsOn = function(element, value, enclosing_tag) {
        // enclosing tag is li by default
        if (!enclosing_tag) {
            enclosing_tag = 'li';
        }
        var elements = this,
            value_on_init = $(element).val();
        //add change handler to element
        $(element).change(function(){
            var $this = $(this);
            var showEm = false;
            if ( $this.is('input[type="checkbox"]') ) {
                showEm = $this.is(':checked');
            } else if ( $this.is('input[type="radio"]') ) {
                showEm = $this.is(':checked');
            } else if ( $this.is('select') ) {
                // var fieldValue = $this.find('option:selected').val();
                var fieldValue = $this.val();

                if ( !value ) {
                    showEm = fieldValue && $.trim(fieldValue) != '';
                } else if (typeof(value) === 'string') {

                    // check for value in multiple selection                      
                    if ($.isArray(fieldValue)) {
                        showEm = ($.inArray(value, fieldValue) !== -1);
                    } else {
                        showEm = value == fieldValue;
                    }

                } else if ($.isArray(value)) {
                    // check for multiple values
                    if ($.isArray(fieldValue)) {
                        // in multiple selection 
                        showEm = $.grep(fieldValue,function(el,i){return $.inArray(el,value) !== -1}).length > 0;
                    } else {
                        // in single selected item
                        showEm = ($.inArray(fieldValue, value) !== -1);
                    }
                }
            }
            elements.closest(enclosing_tag).toggle(showEm);
        });

        //hide the dependent fields
        return elements.each(function(){
            var $this = $(this);
            if (value_on_init != value) {
                $this.closest(enclosing_tag).hide();
            }
        });
    };
})( jQuery );
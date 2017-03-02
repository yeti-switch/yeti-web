// Show/Hide fields that depends on other master field value
$(document).ready(function () {
    $('form').find('[data-depend_selector][data-depend_value]').each(function(inx, el){
        var $dependent = $(el),
            depend_on = $dependent.data('depend_selector'),
            depend_value = $dependent.data('depend_value').toString();
        $dependent.dependsOn(depend_on, depend_value);
    });
});
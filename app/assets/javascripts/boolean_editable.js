$(document).ready(function () {

    $('.editable_column .status_tag').click(function(e){
        self = $(e.currentTarget);
        container = self.closest("div");
        var path = container.data("path");
        var attr = container.data("attr");
        var value = container.data("value");
        var payload = {}
        resource_class = self.closest("tr").attr("id").split("_").slice(0,-1).join("_");
        payload[resource_class] = {};
        payload[resource_class][attr] = value;

        request =  $.ajax({url: path,
               type: "PUT",
               dataType: "json",
               data: payload}).done(function (result) {


            self.toggleClass("ok");
            self.text(value ? "Yes" : "No" );
            container.data("value", !value);
        });

        request.fail(function( jqXHR, textStatus ) {
          alert( "Request failed: " + textStatus );
        });
        return false;
    });

});
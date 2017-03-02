$(document).ready(function (){
  $("#importing_model_select_all").click(function() {
      var c = this.checked;
      $(':checkbox').prop('checked',c);
  });
});

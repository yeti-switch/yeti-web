$.extend $.ui.dialog.prototype.options, {
  create: ->
    $this = $(this);
    $this.parent().find('.ui-dialog-buttonpane button:first').focus()
    $this.keypress (e)->
      if( e.keyCode == $.ui.keyCode.ENTER )
        $this.parent().find('.ui-dialog-buttonpane button:first').click();
        return false;
}

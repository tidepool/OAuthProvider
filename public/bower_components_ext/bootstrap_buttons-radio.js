
define(['jquery'], function($) {
  var setHiddenValue, _me, _radioGroupSel;
  _me = 'bower_components_ext/bootstrap_buttons-radio';
  _radioGroupSel = '[data-toggle="buttons-radio"]';
  setHiddenValue = function($radioGroup) {
    var $group, $hiddenInput, newVal;
    $group = $radioGroup || $(_radioGroupSel);
    newVal = $group.find('.active').val();
    newVal = newVal || $group.find('.active').text().toLowerCase().split(' ').join('');
    $hiddenInput = $group.find('input[type="hidden"]:first');
    return $hiddenInput.val(newVal);
  };
  $('body').delegate(_radioGroupSel, 'click', function() {
    var _this = this;
    return setTimeout(function() {
      return setHiddenValue($(_this));
    }, 5);
  });
  return setHiddenValue;
});

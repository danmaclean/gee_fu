$('#twitter').sharrre({
    share: {
        twitter: true
    },
    enableHover: false,
    enableTracking: true,
    buttons: { twitter: {via: '_JulienH'}},
    click: function(api, options){
        api.simulateClick();
        api.openPopup('twitter');
    }
});
$('#facebook').sharrre({
    share: {
        facebook: true
    },
    enableHover: false,
    enableTracking: true,
    click: function(api, options){
        api.simulateClick();
        api.openPopup('facebook');
    }
});
$('#googleplus').sharrre({
    share: {
        googlePlus: true
    },
    enableHover: false,
    enableTracking: true,
    click: function(api, options){
        api.simulateClick();
        api.openPopup('googlePlus');
    }
});
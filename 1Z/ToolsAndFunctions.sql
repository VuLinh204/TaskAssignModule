uiManager.showAlert({ type: "success",  message: "%VideoCompleted%",});

showConfirmPopup({
    title: "%ConfirmRewatchTitle%",
    message: "%ConfirmRewatchVideoMessage%",
    icon: "",
    YesText: "%Yes%",
    NoText: "%No%",
    onYes: function () {
        openIOSVideo(subj, subjectId, true);
    },
});

import { apiInitializer } from "discourse/lib/api";
import BugReportInstructionsModal from "../components/bug-report-instructions-modal";
import { getOwner } from "@ember/application";
import I18n from "I18n";

export default apiInitializer("0.11.1", api => {
    // Handle opening of the bug instructions modal from inside the d-editor
    api.modifyClass("component:d-editor", {
        pluginId: "discourse-bug-report-instructions",
        actions: {
            openBugInstructionsModal(toolbarEvent) {
                const modal = getOwner(this).lookup("service:modal");
                modal.show(BugReportInstructionsModal, { model: { 
                    initialValue: false,
                    isShown: true, 
                } });
            }
        }
    });
    
    // Add a button to the toolbar
    api.onToolbarCreate(tb => {
        const translation = I18n.t(themePrefix("toolbar.open_bug_instructions"))

        tb.addButton({
            id: 'bug-instructions-button',
            group: 'extras',
            icon: 'info-circle',
            sendAction: (event) => tb.context.send('openBugInstructionsModal', event),
            title: translation
        })
    });

});

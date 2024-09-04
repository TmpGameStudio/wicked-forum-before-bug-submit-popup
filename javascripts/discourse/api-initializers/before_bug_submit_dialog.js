import {apiInitializer} from "discourse/lib/api";
import BugReportInstructionsModal from "../components/bug-report-instructions-modal";
import {getOwner} from "@ember/application";
import I18n from "I18n";
import {getComposerProperties} from '../components/utils'

export default apiInitializer("0.11.1", api => {
    // Handle opening of the bug instructions modal from inside the d-editor
    api.modifyClass("component:d-editor", {
        pluginId: "discourse-bug-report-instructions",
        actions: {
            openBugInstructionsModal(toolbarEvent) {
                const modal = getOwner(this).lookup("service:modal");
                const composer = getOwner(this).lookup("service:composer");
                const properties = getComposerProperties(composer);

                modal.show(BugReportInstructionsModal, {
                    model: {
                        initialValue: false,
                        isShown: true,
                        missingDxdiag: !properties.hasDxdiag,
                        missingAttachment: !properties.hasAttachment,
                        missingImage: !properties.hasImage,
                        missingZipFile: !properties.hasZipFile,
                        missingTags: !properties.hasTags,
                        closeModalAndSubmit: this.closeModalAndSubmit,
                        weblinks: properties.weblinks,
                        logs: properties.logs,
                        isCreatingTopic: properties.isCreatingTopic
                    }
                });
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

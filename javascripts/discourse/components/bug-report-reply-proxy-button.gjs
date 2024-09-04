import Component from "@glimmer/component";
import {tracked} from "@glimmer/tracking";
import {getOwner} from "@ember/application";
import {action} from "@ember/object";
import {schedule} from "@ember/runloop";
import {inject as service} from "@ember/service";
import DButton from "discourse/components/d-button";
import BugReportInstructionsModal from "./bug-report-instructions-modal";
import {getComposerProperties} from './utils';

export default class BugReportReplyProxyButton extends Component {
    @service modal;
    @service siteSettings;
    @service router;
    @service composer;

    @tracked isCreatingTopic = this.composer.model?.creatingTopic;

    localStorageKey = undefined;
    wickedBugsCategoryId = undefined;

    @tracked _showProxyReplyButton = false;

    constructor() {
        super(...arguments);

        this.localStorageKey = settings.local_storage_key;
        this.wickedBugsCategoryId = settings.wicked_bugs_category_id;
        this.wickedBugsCategoryUrl = settings.wicked_bugs_category_url;

        if(!this.isWickedBugsCategory()) {
            return;
        }

        schedule('afterRender', () => {
            this.toggleShowProxyReplyButton(true);
            this.toggleMainReplyButton(false);
        });
    }

    <template>
         {{#if this._showProxyReplyButton}}
            <DButton
            @action={{this.onProxyReplyClicked}}
            @icon={{if this.isCreatingTopic "plus" "reply"}}
            @translatedLabel={{if this.isCreatingTopic "Create Topic" "Reply"}}
            class="btn-primary"
    />
        {{/if}}
    </template>

    /**
     * Toggles the visibility of the main reply button.
     * @param {boolean} show - Whether to show or hide the button.
     */
    @action
    toggleMainReplyButton(show) {
        const button = document.querySelector('#reply-control .save-or-cancel .btn-primary');
        if (button) {
            button.style.display = show ? 'block' : 'none';
        }
    }

    /**
     * Toggles the visibility of the proxy reply button.
     */
    @action
    toggleShowProxyReplyButton(show) {
        this._showProxyReplyButton = show;
    }

    /**
     * Handles the click event on the proxy reply button.
     * This method shows the BugReportInstructionsModal, toggles the visibility
     * of the main reply button, and hides the proxy reply button.
     * It also checks for specific content in the composer.
     */
    @action
    onProxyReplyClicked() {
        schedule('afterRender', () => {
            const composer = this.composer;
            const properties = getComposerProperties(composer);

            this.modal.show(BugReportInstructionsModal, {
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
        });
    }

    /**
     * Checks if the user has dismissed the bug report instructions.
     * @returns {boolean} True if the user has dismissed the instructions, false otherwise.
     */
    userDismissedInstructions() {
        return localStorage.getItem(this.localStorageKey) === 'true';
    }

    /**
     * Checks if the current page is in the Wicked Bugs category.
     * @returns {boolean} True if the page is in the Wicked Bugs category, false otherwise.
     */
    isWickedBugsCategory() {
        // First, check the URL in case user creates new topic under WickedBugs category
        const currentURL = this.router.currentURL;
        if (currentURL.includes(this.wickedBugsCategoryUrl)) {
            return true;
        }

        // If URL check fails, fall back to checking the topic controller
        const topicController = getOwner(this).lookup("controller:topic");

        if (!topicController || !topicController.model) {
            return false;
        }

        return topicController.model.category_id === this.wickedBugsCategoryId;
    }

    @action
    closeModalAndSubmit() {
        this.modal.close();
        this.toggleMainReplyButton(true);
        this.toggleShowProxyReplyButton(false);
        this.submit();
    }

    submit() {
        const button = document.querySelector('#reply-control .save-or-cancel .btn-primary');
        button.click();
    }
}

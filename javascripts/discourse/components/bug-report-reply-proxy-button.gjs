// components/heart-button.gjs
import Component from "@glimmer/component";
import {tracked} from "@glimmer/tracking";
import {getOwner} from "@ember/application";
import {action} from "@ember/object";
import {not} from "@ember/object/computed";
import {schedule} from "@ember/runloop";
import {inject as service} from "@ember/service";
import DButton from "discourse/components/d-button";
import BugReportInstructionsModal from "./bug-report-instructions-modal";

export default class BugReportReplyProxyButton extends Component {
    @service modal;
    @service siteSettings;
     @service router;
    @service composer; 

    @tracked isCreatingTopic = this.composer.model?.creatingTopic;;

    localStorageKey = undefined;
    wickedBugsCategoryId = undefined;

    @tracked _showProxyReplyButton = false;

    constructor() {
        super(...arguments);

        this.localStorageKey = settings.local_storage_key;
        this.wickedBugsCategoryId = settings.wicked_bugs_category_id;

        if(!this.isWickedBugsCategory()) {
            return;
        }

      /*   if(this.userDismissedInstructions()) {
            return;
        } */

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
            const composerContent = this.composer.model?.reply || '';
            const hasDxdiag = composerContent.toLowerCase().includes('dxdiag');
            const logs = {
                playerLog: composerContent.toLowerCase().includes('player.log'),
                playerPrevLog: composerContent.toLowerCase().includes('player-prev.log'),
                datastore: composerContent.toLowerCase().includes('datastore')
            };
            const hasAttachment = this.composer.model?.uploadedFiles?.length > 0;
            const hasImage = composerContent.includes('![');
            const hasZipFile = this.composer.model?.uploadedFiles?.some(file => file.extension === 'zip');
            const hasTags = this.composer.model?.tags?.length > 0;
            const isCreatingTopic = this.composer.model?.creatingTopic;
            const isNew = this.composer.model?.isNew;
            const topicHighestPostNumber = this.composer.model?.topic?.highest_post_number;

            console.log({composerContent, hasDxdiag, logs, hasAttachment, hasImage, hasZipFile, hasTags, isCreatingTopic, isNew, topicHighestPostNumber});
            console.log('Composer service:', this.composer);
            console.log('Composer model:', this.composer.model);

            this.modal.show(BugReportInstructionsModal, {
                model: {
                    initialValue: false,
                    isShown: true,
                    missingDxdiag: !hasDxdiag,
                    missingAttachment: !hasAttachment,
                    missingImage: !hasImage,
                    missingZipFile: !hasZipFile,
                    missingTags: !hasTags,
                    logs,
                    isCreatingTopic,
                    closeModalAndSubmit: this.closeModalAndSubmit
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
    if (currentURL.includes("/c/staff/3")) {
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

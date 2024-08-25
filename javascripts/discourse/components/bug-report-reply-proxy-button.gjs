// components/heart-button.gjs
import {tracked} from "@glimmer/tracking";
import {action} from "@ember/object";
import {inject as service} from "@ember/service";
import DButton from "discourse/components/d-button";
import PostTextSelection from "discourse/components/post-text-selection";
import BugReportInstructionsModal from "./bug-report-instructions-modal";
import {getOwner} from "@ember/application";
import Component from "@glimmer/component";
import {schedule} from "@ember/runloop";

export default class BugReportReplyProxyButton extends Component {
    @service modal;
    @service siteSettings;
     @service router;

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

        if(this.userDismissedInstructions()) {
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
                @icon="reply"  
                @translatedLabel="Reply"
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
    toggleShowProxyReplyButton() {
        this._showProxyReplyButton = !this._showProxyReplyButton;
    }

    /**
     * Handles the click event on the proxy reply button.
     * This method shows the BugReportInstructionsModal, toggles the visibility
     * of the main reply button, and hides the proxy reply button.
     */
    @action
    onProxyReplyClicked() {
        this.modal.show(BugReportInstructionsModal, {
            model: {
                initialValue: false,
                isShown: true,
            }
        });

        this.toggleMainReplyButton(true);
        this.toggleShowProxyReplyButton(false);
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
    if (currentURL.includes("/c/wicked-bug-reporting/13")) {
      return true;
    }

    // If URL check fails, fall back to checking the topic controller
    const topicController = getOwner(this).lookup("controller:topic");

    if (!topicController || !topicController.model) {
      return false;
    }

    return topicController.model.category_id === this.wickedBugsCategoryId;
  }
}

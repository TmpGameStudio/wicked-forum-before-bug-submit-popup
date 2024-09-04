/**
 * Get properties from the composer model.
 * @param {ComposerModel} composerModel - The composer model.
 * @returns {Object} The properties object containing test results.
 */
export function getComposerProperties(composer) {
    const composerContent = composer.model?.reply || '';
    const hasDxdiag = composerContent.toLowerCase().includes('dxdiag');
    const logs = {
        playerLog: composerContent.includes('[player.log|attachment](upload://'),
        playerPrevLog: composerContent.includes('[player-prev.log|attachment](upload://'),
        datastore: composerContent.includes('[datastore.zip|attachment](upload://')
    };
    const hasAttachment = composer.model?.uploadedFiles?.length > 0;
    const hasImage = composerContent.includes('![');
    const hasZipFile = composer.model?.uploadedFiles?.some(file => file.extension === 'zip');
    const weblinks = {
        googleDrive: /https?:\/\/(drive|docs)\.google\.com/.test(composerContent),
        wetransfer: /https?:\/\/(we\.tl\/t-[A-Za-z0-9]+|wetransfer\.com)/.test(composerContent)
    };
    const hasTags = composer.model?.tags?.length > 0;
    const isCreatingTopic = composer.model?.creatingTopic;

    return {
        composerContent,
        hasDxdiag,
        logs,
        hasAttachment,
        hasImage,
        hasZipFile,
        weblinks,
        hasTags,
        isCreatingTopic
    };
}
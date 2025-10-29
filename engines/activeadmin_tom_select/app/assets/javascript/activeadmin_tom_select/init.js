document.addEventListener('DOMContentLoaded', function () {
    // Store TomSelect instances for parent-child communication
    const tomSelectInstances = new Map();

    // Helper function to make parent blink
    function blinkParentFilter(parentInput) {
        if (!parentInput) return;

        const parentTomSelectWrapper = parentInput.parentElement.querySelector('.ts-wrapper') || parentInput.parentElement;
        if (!parentTomSelectWrapper) return;

        // Store original border style
        const originalBorder = parentTomSelectWrapper.style.border || '';
        const originalBoxShadow = parentTomSelectWrapper.style.boxShadow || '';

        // Apply blink border
        const blinkBoxShadow = '0px 0px 0px 2px #5ea3d3';

        // First blink
        parentTomSelectWrapper.style.boxShadow = blinkBoxShadow;
        parentTomSelectWrapper.style.transition = 'border 0.2s, box-shadow 0.2s';

        setTimeout(() => {
            parentTomSelectWrapper.style.boxShadow = originalBoxShadow;

            // Second blink
            setTimeout(() => {
                parentTomSelectWrapper.style.boxShadow = blinkBoxShadow;

                setTimeout(() => {
                    parentTomSelectWrapper.style.boxShadow = originalBoxShadow;

                    // Clean up transition after animation
                    setTimeout(() => {
                        parentTomSelectWrapper.style.transition = '';
                    }, 50);
                }, 80);
            }, 80);
        }, 80);
    }

    // Initialize regular tom-select inputs
    document.querySelectorAll('.tom-select-input').forEach((native_select) => {
        let placeholder = native_select.dataset.placeholder;
        let is_multiple = native_select.getAttribute('multiple') === 'multiple'

        // ✅ Add placeholder as first option if not already present
        if (!native_select.querySelector('option[value=""]') &&
            (native_select.selectedIndex >= 0 &&
                native_select.options[native_select.selectedIndex].getAttribute('selected') !== 'selected')) {

            const placeholderOption = document.createElement('option');
            placeholderOption.value = '';
            placeholderOption.setAttribute('selected', 'selected');
            placeholderOption.innerHTML = placeholder || 'Select an option';
            native_select.prepend(placeholderOption);
        }

        if (native_select.options.length === 0) {
            placeholder = 'There is no any available options';
        }

        // const instance = new TomSelect(native_select, {
        //     placeholder: placeholder || 'Select an option',
        //     allowEmptyOption: true,
        //     plugins: [
        //         {
        //             'clear_button': {
        //                 'title':'Remove all selected options',
        //             }
        //         },
        //         {
        //             'remove_button': {
        //                 title:'Remove this item',
        //             }
        //         },
        //         'input_autogrow',
        //         'dropdown_input',
        //         'caret_position'
        //     ],
        //     persist: false,
        // });
        let plugins = [];

        if (is_multiple) {
            plugins.push('remove_button');
        }
        const instance = new TomSelect(native_select, {
            placeholder: placeholder || 'Select an option',
            allowEmptyOption: true,
            plugins: plugins,
            persist: false,
        });

        // Store instance for potential parent-child relationships
        if (native_select.id) {
            tomSelectInstances.set(native_select.id, instance);
        }
    });

    // Initialize ajax tom-select inputs
    document.querySelectorAll('.ajax-tom-select').forEach((el) => {
        const ajaxUrl = el.dataset.ajaxUrl;
        const placeholder = el.dataset.placeholder;
        const parentFilter = el.dataset.parentFilter;
        const parentParameter = el.dataset.parentParameter;
        const autoFillChildren = el.dataset.autoFillChildren;
        const relatedChildren = el.dataset.relatedChildren;

        // Determine relationship type: is this child in parent's auto-fill list?
        let isAutoFillChild = false;
        if (parentFilter) {
            const parentInput = document.getElementById(parentFilter) ||
                document.querySelector(`[name*="${parentFilter}"]`);
            if (parentInput && parentInput.dataset.autoFillChildren) {
                const parentAutoFillList = parentInput.dataset.autoFillChildren.split(',');
                isAutoFillChild = parentAutoFillList.includes(el.id) ||
                    parentAutoFillList.some(name => el.id.includes(name));
            }
        }

        // Disable child inputs initially if they have a parent
        if (parentFilter && document.querySelector(`[name*="${parentFilter}"]`).value === '') {
            el.disabled = true;
        }

        const instance = new TomSelect(el, {
            placeholder: placeholder || "Type to search records",
            valueField: 'id',
            labelField: 'text',
            loadThrottle: 300,
            preload: isAutoFillChild ? 'focus' : false, // Auto-fill children preload on focus
            load: function(query, callback) {
                // For auto-fill children, allow loading without query on focus
                if (!ajaxUrl) return callback();

                // For related filters (non auto-fill), require query
                if (!isAutoFillChild && !query.length) return callback();

                let url = `${ajaxUrl}${ajaxUrl.includes('?') ? '&' : '?'}`;

                // Add search term if provided
                if (query.length) {
                    url += `term=${encodeURIComponent(query)}`;
                }

                // If this select has a parent filter, append parent value to URL
                if (parentFilter && parentParameter) {
                    const parentInput = document.getElementById(parentFilter) ||
                        document.querySelector(`[name*="${parentFilter}"]`);

                    if (parentInput) {
                        const parentInstance = tomSelectInstances.get(parentInput.id);
                        const parentValue = parentInstance ? parentInstance.getValue() : parentInput.value;

                        if (parentValue) {
                            const separator = url.includes('term=') ? '&' : '';
                            url += `${separator}q[${parentParameter}]=${encodeURIComponent(parentValue)}`;
                        }
                    }
                }

                fetch(url)
                    .then(response => response.json())
                    .then(json => {
                        callback(json.results || []);
                    })
                    .catch(() => {
                        callback();
                    });
            },
            render: {
                option: function(item, escape) {
                    return `<div>${escape(item.text)}</div>`;
                },
                item: function(item, escape) {
                    return `<div>${escape(item.text)}</div>`;
                }
            },
            create: false,
            plugins: [
                {
                    'clear_button': {
                        'title':'Remove all selected options',
                    }
                },
                {
                    'remove_button': {
                        title:'Remove this item',
                    }
                },
                'input_autogrow',
                'dropdown_input',
                'caret_position'
            ],
        });

        if (parentFilter && document.querySelector(`[name*="${parentFilter}"]`).value === '') {
            title = `${document.querySelector(`[name*="${parentFilter}"]`).previousSibling.textContent} field is required`;
            el.parentElement.querySelector('input').style.zIndex = '-5000';
            el.parentElement.querySelector('input').disabled = false;
            el.parentElement.querySelector('input').title = title;
            el.parentElement.querySelector('.ts-wrapper').title = title;
            el.parentElement.querySelector('.ts-wrapper').zIndex = 1000;
        }

        // Customer filter still selected after full HTML reload THEN unblock child fields
        if (parentFilter && document.querySelector(`[name*="${parentFilter}"]`).value !== '') {
            el.parentElement.querySelector('input').style.zIndex = '-1';
            el.parentElement.querySelector('input').disabled = false;
            el.parentElement.querySelector('input').title = '';
            el.parentElement.querySelector('.ts-wrapper').title = ''
            el.parentElement.querySelector('.ts-wrapper').zIndex = '1';
        }

        // Store instance
        if (el.id) {
            tomSelectInstances.set(el.id, instance);
        }

        // Add click blink handler for disabled child filters
        if (parentFilter) {
            const tsWrapper = el.parentElement.querySelector('.ts-wrapper');
            const tsControl = tsWrapper ? tsWrapper.querySelector('.ts-control') : null;

            if (el) {
                el.addEventListener('click', function(e) {
                    // If this child is disabled, blink the parent
                    if (el.disabled || instance.isDisabled) { // el.disabled || instance.isDisabled
                        e.preventDefault();
                        e.stopPropagation();

                        const parentInput = document.getElementById(parentFilter) ||
                            document.querySelector(`[name*="${parentFilter}"]`);

                        blinkParentFilter(parentInput);
                    }
                });
            }

            if (tsControl) {
                tsControl.addEventListener('click', function(e) {
                    // If this child is disabled, blink the parent
                    if (el.disabled || instance.isDisabled) { // el.disabled || instance.isDisabled
                        e.preventDefault();
                        e.stopPropagation();

                        const parentInput = document.getElementById(parentFilter) ||
                            document.querySelector(`[name*="${parentFilter}"]`);

                        blinkParentFilter(parentInput);
                    }
                });
            }

        }

        // Set up parent-child relationship for auto-fill children
        if (autoFillChildren) {

            const autoFillChildIds = autoFillChildren.split(',');

            instance.on('change', function(value) {
                autoFillChildIds.forEach(childFilterId => {
                    const childInput = document.getElementById(childFilterId) || document.querySelector(`[name*="${childFilterId}"]`);

                    if (childInput) {
                        const childInstance = tomSelectInstances.get(childInput.id);
                        if (childInstance) {
                            // If parent input is selected then child elements available
                            if (value) {
                                // Enable child and clear its value
                                childInput.disabled = false;
                                childInstance.enable();
                                childInstance.clear();
                                childInstance.clearOptions();

                                childInput.parentElement.querySelector('input').style.zIndex = '-1';
                                childInput.parentElement.querySelector('input').disabled = true;
                                childInput.parentElement.querySelector('input').title = '';
                                childInput.parentElement.querySelector('.ts-wrapper').title = '';
                                childInput.parentElement.querySelector('.ts-wrapper').zIndex = 1;
                            } else {
                                // Disable child and clear its value
                                childInstance.clear();
                                childInstance.clearOptions();
                                childInstance.disable();
                                childInput.disabled = true;

                                childInput.parentElement.querySelector('input').style.zIndex = '-5000';
                                childInput.parentElement.querySelector('input').disabled = false;
                                childInput.parentElement.querySelector('input').title = title;
                                childInput.parentElement.querySelector('.ts-wrapper').title = title;
                                childInput.parentElement.querySelector('.ts-wrapper').zIndex = 1000;
                            }
                        }
                    }
                });
            });
        }

        // Set up parent-child relationship for related filters
        if (relatedChildren) {
            const relatedChildIds = relatedChildren.split(',');

            instance.on('change', function(value) {
                relatedChildIds.forEach(childFilterId => {
                    const childInput = document.getElementById(childFilterId) ||
                        document.querySelector(`[name*="${childFilterId}"]`);

                    if (childInput) {
                        const childInstance = tomSelectInstances.get(childInput.id);

                        if (childInstance) {
                            if (value) {
                                // Enable child and clear its value
                                childInput.disabled = false;
                                childInstance.enable();
                                childInstance.clear();
                                childInstance.clearOptions();
                            } else {
                                // Disable child and clear its value
                                childInstance.clear();
                                childInstance.clearOptions();
                                childInstance.disable();
                                childInput.disabled = true;
                            }
                        }
                    }
                });
            });
        }
    });
});

# Parent-Child Filter Feature Documentation

## Overview

This feature provides two types of dependent dropdown filters:

1. **Auto-Fill Children** (`auto_fill_in_related_filters`): Pre-loads ALL options when dropdown opens
2. **Related Filters** (`related_filters`): Adds parent as query parameter only when user types

Both types automatically enable/disable based on parent selection.

## Configuration

### Parent Filter with Auto-Fill Children

```ruby
f.input :customer_id, 
  as: :tom_select,
  ajax: {
    resource: Customer,
    auto_fill_in_related_filters: [:comment_id, :contact_id]
  }
```

**Behavior:**
- User selects Customer ID 1
- User clicks Comment dropdown → **Immediately** loads all comments for Customer 1
- No typing required
- Request: `/admin/comments/all_options?q[customer_id_eq]=1`

### Parent Filter with Related Children

```ruby
f.input :customer_id,
  as: :tom_select,
  ajax: {
    resource: Customer,
    related_filters: [:address_id]
  }
```

**Behavior:**
- User selects Customer ID 1
- User clicks Address dropdown → Shows "Type to search"
- User types "Main" → Request: `/admin/addresses/all_options?term=Main&q[customer_id_eq]=1`
- Parent value only added as filter when typing

### Child Filter Configuration (Same for Both Types)

```ruby
f.input :comment_id,
  as: :tom_select,
  ajax: {
    resource: Comment,
    parent_filter: :customer_id,              # Required: parent field name
    parent_param: 'customer_id_eq'            # Optional: defaults to "parent_filter_name_eq"
  }
```

## Complete Example

### Step 1: Set up searchable_select_options

```ruby
# app/admin/customers.rb
ActiveAdmin.register Customer do
  searchable_select_options(
    scope: -> { Customer.all },
    text_attribute: :name
  )
end

# app/admin/comments.rb
ActiveAdmin.register Comment do
  searchable_select_options(
    scope: ->(params) {
      scope = Comment.all
      # Filter by customer_id if provided
      if params[:q] && params[:q][:customer_id_eq]
        scope = scope.where(customer_id: params[:q][:customer_id_eq])
      end
      scope
    },
    text_attribute: :body
  )
end

# app/admin/addresses.rb
ActiveAdmin.register Address do
  searchable_select_options(
    scope: ->(params) {
      scope = Address.all
      # Filter by customer_id if provided
      if params[:q] && params[:q][:customer_id_eq]
        scope = scope.where(customer_id: params[:q][:customer_id_eq])
      end
      scope
    },
    text_attribute: :street_name
  )
end
```

### Step 2: Use in your form

```ruby
# app/admin/orders.rb
ActiveAdmin.register Order do
  permit_params :customer_id, :comment_id, :address_id

  form do |f|
    f.inputs do
      # Parent with mixed children types
      f.input :customer_id, 
        as: :tom_select,
        ajax: {
          resource: Customer,
          auto_fill_in_related_filters: [:comment_id],  # Pre-loads options
          related_filters: [:address_id]                # Type-to-search
        },
        input_html: { id: 'customer_id' }

      # Auto-fill child: loads all options on open
      f.input :comment_id,
        as: :tom_select,
        ajax: {
          resource: Comment,
          parent_filter: :customer_id
        },
        input_html: { id: 'comment_id' }

      # Related child: requires typing to search
      f.input :address_id,
        as: :tom_select,
        ajax: {
          resource: Address,
          parent_filter: :customer_id
        },
        input_html: { id: 'address_id' }
    end

    f.actions
  end
end
```

## Behavior Comparison

### Auto-Fill Children Flow

1. ✅ User selects Customer ID 1
2. ✅ Comment filter becomes enabled (but still empty)
3. ✅ User **clicks** on Comment dropdown
4. ✅ **Immediately** AJAX request: `/admin/comments/all_options?q[customer_id_eq]=1`
5. ✅ Shows all 50 comments for Customer 1 (no typing needed)
6. ✅ User can scroll and select

**Use when:** Child has small number of options (< 100) or user needs to see all available options

### Related Filters Flow

1. ✅ User selects Customer ID 1
2. ✅ Address filter becomes enabled
3. ✅ User clicks on Address dropdown
4. ✅ Shows placeholder "Type to search"
5. ✅ User types "Main"
6. ✅ AJAX request: `/admin/addresses/all_options?term=Main&q[customer_id_eq]=1`
7. ✅ Shows only addresses matching "Main" for Customer 1

**Use when:** Child has many options (> 100) or search/filtering is expected

## Advanced Examples

### Multiple Children of Different Types

```ruby
f.input :customer_id,
  as: :tom_select,
  ajax: {
    resource: Customer,
    # These pre-load on dropdown open
    auto_fill_in_related_filters: [:comment_id, :contact_id, :project_id],
    # These only filter when user types
    related_filters: [:address_id, :invoice_id, :document_id]
  }
```

### Custom Parent Parameter Name

```ruby
f.input :comment_id,
  as: :tom_select,
  ajax: {
    resource: Comment,
    parent_filter: :customer_id,
    parent_param: 'owner_id_eq'  # Custom param name
  }
```

AJAX request will be: `/admin/comments/all_options?q[owner_id_eq]=1`

### Using in Filters

```ruby
ActiveAdmin.register Order do
  filter :customer_id,
    as: :tom_select,
    ajax: {
      resource: Customer,
      auto_fill_in_related_filters: [:comment_id],
      related_filters: [:address_id]
    }

  filter :comment_id,
    as: :tom_select,
    ajax: {
      resource: Comment,
      parent_filter: :customer_id
    }

  filter :address_id,
    as: :tom_select,
    ajax: {
      resource: Address,
      parent_filter: :customer_id
    }
end
```

## Technical Details

### Data Attributes Generated

**Parent with auto-fill:**
```html
<select data-auto-fill-children="comment_id,contact_id">
```

**Parent with related:**
```html
<select data-related-children="address_id,invoice_id">
```

**Child:**
```html
<select data-parent-filter="customer_id" data-parent-param="customer_id_eq">
```

### TomSelect Configuration Differences

**Auto-fill child:**
```javascript
{
  preload: 'focus',  // Load on dropdown open
  load: function(query, callback) {
    // Allows empty query, loads all options
  }
}
```

**Related child:**
```javascript
{
  preload: false,  // Don't preload
  load: function(query, callback) {
    // Requires query.length > 0 to search
  }
}
```

## Important Notes

1. **Performance**: Use `auto_fill_in_related_filters` only for child collections with < 100 records to avoid slow loading

2. **HTML IDs**: Ensure inputs have consistent `id` attributes for parent-child detection

3. **Query Parameters**: Parent value always sent as `q[parent_param_name]` format

4. **Mixed Usage**: You can use both `auto_fill_in_related_filters` and `related_filters` on the same parent

5. **Clearing Parent**: When parent is cleared, all children (both types) are disabled and cleared

## Troubleshooting

### Auto-fill child not loading options on open
- Check `auto_fill_in_related_filters` array includes correct child field name
- Verify child's `searchable_select_options` scope accepts empty term parameter
- Check browser console for AJAX errors

### Related child not filtering by parent
- Ensure `parent_filter` matches parent field name
- Verify scope handles the query parameter correctly
- Check AJAX URL in network tab

### Child always requires typing (even for auto-fill)
- Confirm child is listed in `auto_fill_in_related_filters` (not `related_filters`)
- Check child input has correct `id` attribute
- Verify parent has `data-auto-fill-children` attribute in HTML
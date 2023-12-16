class InvoiceReverseBilling < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table billing.invoice_originated_networks add spent boolean not null default true;
      alter table billing.invoice_terminated_networks add spent boolean not null default false;
      alter table billing.invoice_originated_destinations add spent boolean not null default true;
      alter table billing.invoice_terminated_destinations add spent boolean not null default false;

      alter table billing.invoices
        rename column terminated_amount to terminated_amount_earned;

      alter table billing.invoices
        rename column originated_amount to originated_amount_spent;

      alter table billing.invoices
        add terminated_amount_spent numeric not null default 0,
        add originated_amount_earned numeric not null default 0,
        add amount_spent numeric not null default 0,
        add amount_earned numeric not null default 0,
        add amount_total numeric not null default 0;
    }
  end

  def down
    execute %q{
      alter table billing.invoice_originated_networks drop column spent;
      alter table billing.invoice_terminated_networks drop column spent;
      alter table billing.invoice_originated_destinations drop column spent;
      alter table billing.invoice_terminated_destinations drop column spent;

      alter table billing.invoices
        rename column terminated_amount_earned to terminated_amount;

      alter table billing.invoices
        rename column originated_amount_spent to originated_amount;

      alter table billing.invoices
        drop column terminated_amount_spent,
        drop column originated_amount_earned,
        drop column amount_spent,
        drop column amount_earned,
        drop column amount_total;
    }
  end
end

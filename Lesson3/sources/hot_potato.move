module sui_mover_lesson_3::hot_potato {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};

    const ELoanAmountExceedPool: u64 = 0;
    const ERepayAmountInvalid: u64 = 1;

    public struct LoanPool has key {
        id: UID,
        amount: Balance<SUI>,
    }

    /// Hot Potato
    public struct Loan {
        amount: u64
    }

    public fun borrow(
        pool: &mut LoanPool,
        amount: u64,
        ctx: &mut TxContext
    ): (Coin<SUI>, Loan) {
        assert!(amount <= balance::value(&pool.amount), ELoanAmountExceedPool);

        let coin = coin::from_balance(pool.amount.split(amount), ctx);
        let loan = Loan {
            amount
        };

        (coin, loan)
    }

    public fun repay(pool: &mut LoanPool, loan: Loan, payment: Coin<SUI>) {
        let Loan { amount } = loan;
        assert!(coin::value(&payment) == amount, ERepayAmountInvalid);

        pool.amount.join(payment.into_balance());
    }
}

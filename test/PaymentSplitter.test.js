const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test PaymentSpilitter", () => {
  before(async () => {
    [owner, addr1, addr2, addr3, addr4, addr4, addr5, ...addrs] =
      await ethers.getSigners();

    paymentSplitterFactory = await ethers.getContractFactory("PaymentSplitter");
    paymentSplitter = await paymentSplitterFactory.connect(owner).deploy();

    testFactory = await ethers.getContractFactory("TEST");
    testToken = await testFactory
      .connect(owner)
      .deploy(ethers.utils.parseEther("10000000000000"));

  });

  describe("Check deployment", () => {
    it("should set owner correctly", async () => {
      expect(await paymentSplitter.owner()).to.equal(owner.address);
    });
  });

  describe("Check functions", () => {
    it("addPayee(address _account, uint256 _shares)", async () => {
      await expect(
        paymentSplitter
          .connect(owner)
          .addPayee(addr1.address, ethers.utils.parseEther("0"))
      ).to.be.revertedWith("PaymentSplitter: shares are 0");

      await expect(
        paymentSplitter
          .connect(owner)
          .addPayee(addr1.address, ethers.utils.parseEther("1"))
      )
        .to.emit(paymentSplitter, "PayeeAdded")
        .withArgs(addr1.address, ethers.utils.parseEther("1"));

      expect(await paymentSplitter.shares(addr1.address)).to.equal(
        ethers.utils.parseEther("1"),
        "set shares"
      );
      expect(await paymentSplitter.isEnabled(addr1.address)).to.equal(
        true,
        "set enable"
      );
      expect(await paymentSplitter.isPayee(addr1.address)).to.equal(
        true,
        "set isPayFee"
      );

      const listPayees = await paymentSplitter.connect(owner).listOfPayees();
      expect(listPayees.length).to.equal(1);
      expect(listPayees[0]).to.equal(addr1.address, "add payee to payee list");

      expect(await paymentSplitter.totalShares()).to.equal(
        ethers.utils.parseEther("1"),
        "increate total shares"
      );

      await expect(
        paymentSplitter
          .connect(owner)
          .addPayee(addr1.address, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("PaymentSplitter: account is already a payee");
    });

    it("removePayee(address _account)", async () => {
      await expect(
        paymentSplitter.connect(owner).removePayee(addr2.address)
      ).to.be.revertedWith("PaymentSplitter: account not added");

      await expect(paymentSplitter.connect(owner).removePayee(addr1.address))
        .to.emit(paymentSplitter, "PayeeRemoved")
        .withArgs(addr1.address);

      expect(await paymentSplitter.totalShares()).to.equal(
        ethers.utils.parseEther("0"),
        "decreate total shares"
      );

      const listPayees = await paymentSplitter.connect(owner).listOfPayees();
      expect(listPayees.length).to.equal(0, "remove payee from payee list");
    });

    it("updatePayeeShares(address _account, uint256 _shares)", async () => {
      await expect(
        paymentSplitter
          .connect(owner)
          .updatePayeeShares(addr1.address, ethers.utils.parseEther("2"))
      ).to.be.revertedWith("PaymentSplitter: account not added");

      await paymentSplitter
        .connect(owner)
        .addPayee(addr1.address, ethers.utils.parseEther("1"));

      await expect(
        paymentSplitter
          .connect(owner)
          .updatePayeeShares(addr1.address, ethers.utils.parseEther("0"))
      ).to.be.revertedWith(
        "PaymentSplitter: cannot update to 0, please remove the Payee instead"
      );

      await expect(
        paymentSplitter
          .connect(owner)
          .updatePayeeShares(addr1.address, ethers.utils.parseEther("2"))
      )
        .to.emit(paymentSplitter, "PayeeUpdatedShares")
        .withArgs(
          addr1.address,
          ethers.utils.parseEther("1"),
          ethers.utils.parseEther("2")
        );

      expect(await paymentSplitter.shares(addr1.address)).to.equal(
        ethers.utils.parseEther("2"),
        "update shares"
      );

      expect(await paymentSplitter.totalShares()).to.equal(
        ethers.utils.parseEther("2"),
        "update total shares"
      );
    });

    it("updatePayeeStatus(address _account, bool _status)", async () => {
      await expect(
        paymentSplitter.connect(owner).updatePayeeStatus(addr2.address, false)
      ).to.be.revertedWith("PaymentSplitter: account not added");

      await expect(
        paymentSplitter.connect(owner).updatePayeeStatus(addr1.address, false)
      )
        .to.emit(paymentSplitter, "PayeeUpdatedStatus")
        .withArgs(addr1.address, true, false);

      expect(await paymentSplitter.isEnabled(addr1.address)).to.equal(
        false,
        "set enable"
      );

      await paymentSplitter
        .connect(owner)
        .updatePayeeStatus(addr1.address, true);

      expect(await paymentSplitter.isEnabled(addr1.address)).to.equal(
        true,
        "restore"
      );
    });

    it("releaseEth()", async () => {
      await expect(
        paymentSplitter.connect(owner).releaseEth()
      ).to.be.revertedWith("PaymentSplitter: account is not due payment");

      await paymentSplitter
        .connect(owner)
        .addPayee(addr2.address, ethers.utils.parseEther("2"));

      await owner.sendTransaction({
        to: paymentSplitter.address,
        value: ethers.utils.parseEther("1").toHexString(),
      });

      await expect(paymentSplitter.connect(owner).releaseEth())
        .to.emit(paymentSplitter, "EthPaymentReleased")
        .withArgs(addr1.address, ethers.utils.parseEther("0.5"))
        .to.emit(paymentSplitter, "EthPaymentReleased")
        .withArgs(addr1.address, ethers.utils.parseEther("0.5"));

      expect(await paymentSplitter.ethReleased(addr1.address)).to.equal(
        ethers.utils.parseEther("0.5")
      );
      expect(await paymentSplitter.ethReleased(addr2.address)).to.equal(
        ethers.utils.parseEther("0.5")
      );
      expect(await paymentSplitter.totalEthReleased()).to.equal(
        ethers.utils.parseEther("1")
      );
    });

    it("releaseEr20()", async () => {
      await expect(
        paymentSplitter.connect(owner).releaseEr20(testToken.address)
      ).to.be.revertedWith("PaymentSplitter: account is not due payment");

      await testToken
        .connect(owner)
        .transfer(paymentSplitter.address, ethers.utils.parseEther("1"));

      await expect(
        paymentSplitter.connect(owner).releaseEr20(testToken.address)
      )
        .to.emit(paymentSplitter, "ERC20PaymentReleased")
        .withArgs(
          testToken.address,
          addr1.address,
          ethers.utils.parseEther("0.5")
        )
        .to.emit(paymentSplitter, "ERC20PaymentReleased")
        .withArgs(
          testToken.address,
          addr1.address,
          ethers.utils.parseEther("0.5")
        );

      expect(
        await paymentSplitter.erc20Released(testToken.address, addr1.address)
      ).to.equal(ethers.utils.parseEther("0.5"));
      expect(
        await paymentSplitter.erc20Released(testToken.address, addr2.address)
      ).to.equal(ethers.utils.parseEther("0.5"));
      expect(
        await paymentSplitter.totalERC20Released(testToken.address)
      ).to.equal(ethers.utils.parseEther("1"));
    });

    it("withdrawEth(address payable receiver, uint256 amount)", async () => {
      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawEth(
            ethers.constants.AddressZero,
            ethers.utils.parseEther("1")
          )
      ).to.be.revertedWith("PaymentSplitter: receiver is the zero address");

      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawEth(addr1.address, ethers.utils.parseEther("0"))
      ).to.be.revertedWith("PaymentSplitter: amount is the zero");

      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawEth(addr1.address, ethers.utils.parseEther("1"))
      ).to.be.revertedWith("PaymentSplitter: not enough balance");

      await owner.sendTransaction({
        to: paymentSplitter.address,
        value: ethers.utils.parseEther("1").toHexString(),
      });

      const _beforeBal = await ethers.provider.getBalance(addr1.address);
      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawEth(addr1.address, ethers.utils.parseEther("1"))
      )
        .to.emit(paymentSplitter, "EthPaymentWithdrawed")
        .withArgs(addr1.address, ethers.utils.parseEther("1"));
      const _afterBal = await ethers.provider.getBalance(addr1.address);
      expect(_afterBal.sub(_beforeBal)).to.equal(ethers.utils.parseEther("1"));
      expect(
        await ethers.provider.getBalance(paymentSplitter.address)
      ).to.equal(0);
    });

    it("withdrawERC20(IERC20 token, address receiver, uint256 amount)", async () => {
      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawERC20(
            testToken.address,
            ethers.constants.AddressZero,
            ethers.utils.parseEther("1")
          )
      ).to.be.revertedWith("PaymentSplitter: receiver is the zero address");

      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawERC20(
            testToken.address,
            addr1.address,
            ethers.utils.parseEther("0")
          )
      ).to.be.revertedWith("PaymentSplitter: amount is the zero");

      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawERC20(
            testToken.address,
            addr1.address,
            ethers.utils.parseEther("1")
          )
      ).to.be.revertedWith("PaymentSplitter: not enough balance");

      await testToken
        .connect(owner)
        .transfer(paymentSplitter.address, ethers.utils.parseEther("1"));

      const _beforeBal = await testToken.balanceOf(addr1.address);
      await expect(
        paymentSplitter
          .connect(owner)
          .withdrawERC20(
            testToken.address,
            addr1.address,
            ethers.utils.parseEther("1")
          )
      )
        .to.emit(paymentSplitter, "ERC20PaymentWithdrawed")
        .withArgs(
          testToken.address,
          addr1.address,
          ethers.utils.parseEther("1")
        );
      const _afterBal = await testToken.balanceOf(addr1.address);
      expect(_afterBal.sub(_beforeBal)).to.equal(ethers.utils.parseEther("1"));
      expect(await testToken.balanceOf(paymentSplitter.address)).to.equal(0);
    });
  });
});

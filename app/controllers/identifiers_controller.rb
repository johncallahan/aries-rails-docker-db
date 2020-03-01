class IdentifiersController < ApplicationController
  before_action :set_identifier, only: [:show, :edit, :update, :destroy]

  # GET /identifiers
  # GET /identifiers.json
  def index
    @identifiers = Identifier.all
  end

  # GET /identifiers/1
  # GET /identifiers/1.json
  def show
  end

  # GET /identifiers/new
  def new
    @identifier = Identifier.new
  end

  # GET /identifiers/1/edit
  def edit
  end

  # POST /identifiers
  # POST /identifiers.json
  def create
    @identifier = Identifier.new(identifier_params)
    @identifier.did, @identifier.verkey = create_did()

    respond_to do |format|
      if @identifier.save
        format.html { redirect_to @identifier, notice: 'Identifier was successfully created.' }
        format.json { render :show, status: :created, location: @identifier }
      else
        format.html { render :new }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identifiers/1
  # PATCH/PUT /identifiers/1.json
  def update
    respond_to do |format|
      if @identifier.update(identifier_params)
        format.html { redirect_to @identifier, notice: 'Identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @identifier }
      else
        format.html { render :edit }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.json
  def destroy
    @identifier.destroy
    respond_to do |format|
      format.html { redirect_to identifiers_url, notice: 'Identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identifier
      @identifier = Identifier.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def identifier_params
      params.require(:identifier).permit(:did, :verkey)
    end

    def create_did
      begin
        pool = AriesPool.new("POOLX1")
        pool.create
        pool.open
        rescue RuntimeError => e
          did = "cannot create at this time (pool error)"
          verkey = nil
          return did, verkey
      end

      begin
        wallet = AriesWallet.new(SecureRandom.hex)
        wallet.create
        wallet.open
        steward_did = AriesDID.new()
        seed = AriesJson.to_string('{"seed":"000000000000000000000000Steward1"}')
        steward_did.create(wallet,seed)
        rescue RuntimeError => e
	  pool.close
          pool.delete
          did = "cannot create at this time (steward wallet error)"
          verkey = nil
          return did, verkey
      end

      begin
        trustee_did = AriesDID.new()
        trustee_did.create(wallet,"{}")
        puts trustee_did.get_verkey
        rescue RuntimeError => e
          wallet.close
          wallet.delete
          pool.close
          pool.delete
          did = "cannot create at this time (trustee DID error)"
          verkey = nil
          return did, verkey
      end

      begin
        otherWallet = AriesWallet.new(SecureRandom.hex)
        otherWallet.create
        otherWallet.open
        rescue RuntimeError => e
          wallet.close
          wallet.delete
          pool.close
          pool.delete
          did = "cannot create at this time (other wallet error)"
          verkey = nil
          return did, verkey
      end

      begin
        nym = AriesDID.build_nym(steward_did,trustee_did)
        puts nym
        ssresult = steward_did.sign_and_submit_request(pool,wallet,nym)
        puts ssresult
        rescue RuntimeError => e
          wallet.close
          wallet.delete
          otherWallet.close
          otherWallet.delete
          pool.close
          pool.delete
          did = "cannot create at this time (NYM error)"
          verkey = nil
          return did, verkey
      end

      did = trustee_did.get_did
      verkey = trustee_did.get_verkey

      wallet.close
      wallet.delete
      otherWallet.close
      otherWallet.delete
      pool.close
      pool.delete

      return did, verkey
    end
end

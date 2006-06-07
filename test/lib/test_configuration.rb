module TestConfiguration

private

  def ensure_logged_in
    user = FlexMock.new
    user.should_receive(:login).and_return('motiro')

    @request.session[:user] = user
  end

end
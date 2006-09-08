module TestConfiguration

private

  def ensure_logged_in
    user = FlexMock.new
    user.should_receive(:login).and_return('motiro')
    user.should_receive(:can_edit?).with_any_args.and_return(true)
    user.should_receive(:can_change_editors?).with_any_args.and_return(true)

    @request.session[:user] = user
  end

end